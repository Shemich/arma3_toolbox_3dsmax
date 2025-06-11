	/*
 * P3D File Importer for 3ds Max
 * Description: Imports a P3D (MLOD) file into 3ds Max, reading points, normals, faces, and selections
 *              for both geometry and memory LODs. Creates meshes for geometry LODs and point helpers
 *              for memory LODs, with selection groups applied.
 * Usage: Run this script in 3ds Max, select a .p3d file, and it will import the data into the scene.
 * Note: Assumes MLOD format with structure matching the provided exporter.
 */

-- Define structs mirroring the exporter for reading P3D data
struct vertexStruct
(
    pointID, normalID, u, v
)

struct normalStruct
(
    x, y, z
)

struct pointStruct
(
    x, y, z, flags
)

struct faceStruct
(
    numVerts, flags, textureName, materialName
)

struct selNameStruct
(
    bool, tagName, numBytes
)

struct sharpEdgeStruct
(
    bool, tagName, numBytes
)

struct uvStruct
(
    bool, tagName, uvSetID, numBytes
)

struct endOfFile
(
    bool, tagName, bytes
)

struct lodStruct
(
    lodType, majVer, minVer, numPointsLod, numNormalsLod, numFacesLod, unknown, tagg, resolution
)

-- Main P3D importer struct
struct p3dImporter
(
    fileType, version, noOfLods, filePath, fileStream,
    
    -- Function to read a string until null byte (0x00)
    fn readNullTerminatedString f =
    (
        local str = ""
        local byte = 0
        while (byte = readByte f) != 0x00 do
        (
            if byte == undefined do return str
            str += (bit.intAsChar byte)
        )
        return str
    ),
    
    -- Function to import the P3D file
    fn importFile =
    (
        try (
            -- Open the file in binary read mode
            fileStream = fopen filePath "rb"
            if fileStream == undefined do
            (
                messageBox "Failed to open P3D file!"
                return false
            )
            
            -- Read header
            fileType = readNullTerminatedString fileStream
            fseek fileStream 4 #seek_set -- Skip 4 bytes
            version = readLong fileStream
            noOfLods = readLong fileStream
            format "Debug: File Type: %, Version: %, Number of LODs: %\n" fileType version noOfLods
            
            if version != 257 do
            (
                messageBox "Invalid P3D file format or version!"
                fclose fileStream
                return false
            )
            
            -- Process each LOD
            for i = 1 to noOfLods do
            (
                -- Read LOD header
                local newLod = lodStruct()
                newLod.lodType = readNullTerminatedString fileStream
                newLod.majVer = readLong fileStream
                newLod.minVer = readLong fileStream
                newLod.numPointsLod = readLong fileStream
                newLod.numNormalsLod = readLong fileStream
                newLod.numFacesLod = readLong fileStream
                newLod.unknown = readLong fileStream
                format "Debug: LOD % - Type: %, Points: %, Normals: %, Faces: %, Resolution: TBD\n" i newLod.lodType newLod.numPointsLod newLod.numNormalsLod newLod.numFacesLod
                
                -- Arrays to store data
                local points = #()
                local normals = #()
                local faces = #()
                local vertices = #()
                local selections = #()
                local uvCoords = #()
                
                -- Read points
                for j = 1 to newLod.numPointsLod do
                (
                    local newPoint = pointStruct()
                    newPoint.x = readFloat fileStream
                    newPoint.z = readFloat fileStream
                    newPoint.y = readFloat fileStream
                    newPoint.flags = readLong fileStream
                    append points newPoint
                    format "Debug: Point %: [% , % , %], Flags: %\n" j newPoint.x newPoint.y newPoint.z newPoint.flags
                )
                
                -- Read normals
                for j = 1 to newLod.numNormalsLod do
                (
                    local newNormal = normalStruct()
                    newNormal.x = readFloat fileStream
                    newNormal.z = readFloat fileStream
                    newNormal.y = readFloat fileStream
                    append normals newNormal
                    format "Debug: Normal %: [% , % , %]\n" j newNormal.x newNormal.y newNormal.z
                )
                
                -- Read faces (only for non-memory LODs)
                if newLod.numFacesLod > 0 do
                (
                    for f = 1 to newLod.numFacesLod do
                    (
                        local newFace = faceStruct()
                        newFace.numVerts = readLong fileStream
                        local faceVerts = #()
                        for v = 1 to newFace.numVerts do
                        (
                            local vert = vertexStruct()
                            vert.pointID = readLong fileStream
                            vert.normalID = readLong fileStream
                            vert.u = readFloat fileStream
                            vert.v = readFloat fileStream
                            append faceVerts vert
                        )
                        newFace.flags = readLong fileStream
                        newFace.textureName = readNullTerminatedString fileStream
                        newFace.materialName = readNullTerminatedString fileStream
                        append faces newFace
                        append vertices faceVerts
                        format "Debug: Face %: Verts: %, Texture: %, Material: %\n" f newFace.numVerts newFace.textureName newFace.materialName
                    )
                )
                
                -- Read TAGG section
                local tagg = readNullTerminatedString fileStream
                if tagg != "TAGG" do
                (
                    messageBox "Invalid TAGG section in LOD!"
                    fclose fileStream
                    return false
                )
                
                -- Read tags until EndOfFile
                local endReached = false
                while not endReached do
                (
                    local boolVal = readByte fileStream
                    if boolVal == undefined do
                    (
                        messageBox "Unexpected end of file in TAGG section!"
                        fclose fileStream
                        return false
                    )
                    local tagName = readNullTerminatedString fileStream
                    local numBytes = readLong fileStream
                    
                    if tagName == "#EndOfFile#" then
                    (
                        local eof = endOfFile()
                        eof.bool = boolVal
                        eof.tagName = tagName
                        eof.bytes = numBytes
                        newLod.resolution = readFloat fileStream
                        endReached = true
                        format "Debug: End of LOD % - Resolution: %\n" i newLod.resolution
                    )
                    else if tagName == "#SharpEdges#" then
                    (
                        local sharp = sharpEdgeStruct bool:boolVal tagName:tagName numBytes:numBytes
                        format "Debug: Sharp Edges - Bytes: %\n" sharp.numBytes
                        fseek fileStream sharp.numBytes #seek_cur -- Skip sharp edges data
                    )
                    else if tagName == "#UVSet#" then
                    (
                        local uvSet = uvStruct bool:boolVal tagName:tagName numBytes:numBytes
                        uvSet.uvSetID = readLong fileStream
                        local uvData = #()
                        for v = 1 to (numBytes - 4) / 8 do -- Each UV is 2 floats (8 bytes)
                        (
                            local uv = #()
                            uv[1] = readFloat fileStream -- u
                            uv[2] = readFloat fileStream -- v
                            append uvData uv
                        )
                        append uvCoords uvSet
                        format "Debug: UV Set % - ID: %, UV Count: %\n" uvSet.uvSetID uvData.count
                    )
                    else
                    (
                        -- Assume selection tag
                        local sel = selNameStruct bool:boolVal tagName:tagName numBytes:numBytes
                        local selBytes = #()
                        for b = 1 to numBytes do
                        (
                            append selBytes (readByte fileStream)
                        )
                        append selections sel
                        format "Debug: Selection - Name: %, Bytes: %\n" sel.tagName sel.numBytes
                    )
                )
                
                -- Create the LOD in 3ds Max
                if newLod.resolution == 1.0e15 then
                (
                    -- Memory LOD: Create point helpers
                    for p = 1 to points.count do
                    (
                        local pt = point pos:[points[p].x, points[p].z, points[p].y] name:("MemoryPoint_" + p as string)
                        -- Apply selections
                        for sel in selections do
                        (
                            if sel.numBytes > p and selBytes[p] == 0x01 do
                            (
                                pt.name = sel.tagName
                            )
                        )
                    )
                    format "Debug: Created % point helpers for Memory LOD\n" points.count
                )
                else
                (
                    -- Geometry LOD: Create a mesh
                    local meshVerts = #()
                    for p in points do
                    (
                        append meshVerts [p.x, p.z, p.y] -- Swap z and y for 3ds Max
                    )
                    
                    local meshFaces = #()
                    local meshUVs = #()
                    for f = 1 to faces.count do
                    (
                        local faceVerts = vertices[f]
                        local faceIndices = #()
                        for v = 1 to faces[f].numVerts do
                        (
                            if faceVerts[v].pointID != 0 do -- Skip dummy verts (pointID 0)
                            (
                                append faceIndices (faceVerts[v].pointID + 1) -- 1-based for 3ds Max
                            )
                        )
                        if faceIndices.count == 3 then
                        (
                            append meshFaces faceIndices
                            append meshUVs [faceVerts[1].u, faceVerts[1].v, 0]
                            append meshUVs [faceVerts[2].u, faceVerts[2].v, 0]
                            append meshUVs [faceVerts[3].u, faceVerts[3].v, 0]
                        )
                        else if faceIndices.count == 4 then
                        (
                            -- Split quad into two triangles
                            append meshFaces [faceIndices[1], faceIndices[2], faceIndices[3]]
                            append meshUVs [faceVerts[1].u, faceVerts[1].v, 0]
                            append meshUVs [faceVerts[2].u, faceVerts[2].v, 0]
                            append meshUVs [faceVerts[3].u, faceVerts[3].v, 0]
                            append meshFaces [faceIndices[1], faceIndices[3], faceIndices[4]]
                            append meshUVs [faceVerts[1].u, faceVerts[1].v, 0]
                            append meshUVs [faceVerts[3].u, faceVerts[3].v, 0]
                            append meshUVs [faceVerts[4].u, faceVerts[4].v, 0]
                        )
                    )
                    
                    -- Create the mesh
                    local newMesh = mesh vertices:meshVerts faces:meshFaces name:("LOD_" + newLod.resolution as string)
                    update newMesh
                    
                    -- Apply UVs
                    if meshUVs.count > 0 do
                    (
                        setNumTVerts newMesh meshUVs.count
                        for i = 1 to meshUVs.count do
                        (
                            setTVert newMesh i meshUVs[i]
                        )
                        buildTVFaces newMesh
                        for f = 1 to meshFaces.count do
                        (
                            setTVFace newMesh f [f*3-2, f*3-1, f*3]
                        )
                    )
                    
                    -- Apply material and texture (basic assignment)
                    if faces.count > 0 and faces[1].materialName != "" do
                    (
                        newMesh.material = standardMaterial name:faces[1].materialName
                        if faces[1].textureName != "" do
                        (
                            newMesh.material.diffuseMap = bitmapTexture filename:faces[1].textureName
                        )
                    )
                    
                    -- Apply selections
                    for sel in selections do
                    (
                        local vertSel = #()
                        for v = 1 to newMesh.numVerts do
                        (
                            if sel.numBytes > v and selBytes[v] == 0x01 do
                            (
                                append vertSel v
                            )
                        )
                        if vertSel.count > 0 do
                        (
                            setVertSelection newMesh vertSel
                            max modify mode
                            select newMesh
                            subObjectLevel = 1
                            polyOp.setVertSelection newMesh vertSel
                            max create mode
                            newMesh.name = sel.tagName
                        )
                    )
                    format "Debug: Created mesh for LOD % with % verts, % faces\n" i newMesh.numVerts newMesh.numFaces
                )
            )
            
            fclose fileStream
            format "Debug: Import successful!\n"
            true
        ) catch (
            format "Debug: ERROR - Exception caught during import: %\n" (getCurrentException())
            if fileStream != undefined do fclose fileStream
            messageBox "Failed to import P3D file! Check MaxScript Listener for details."
            false
        )
    )
)

-- Usage: Create importer, prompt for file, and import
(
    local importer = p3dImporter()
    importer.filePath = getOpenFileName caption:"Select P3D File to Import" types:"P3D Files (*.p3d)|*.p3d|All Files (*.*)|*.*|"
    if importer.filePath != undefined do
    (
        importer.importFile()
    )
)