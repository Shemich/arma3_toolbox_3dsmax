struct vertexStruct
(
    pointID,
    normalID,
    u,
    v
)
struct normalStruct
(
    x,
    y,
    z,
    
    function point3toPoint coord=
    (
        x = coord.x
        y = coord.y
        z = coord.z
    )
)
struct pointStruct
(
    x,
    y,
    z,
    flags = 0,
    
    function point3toPoint coord=
    (
        x = coord.x
        y = coord.y
        z = coord.z
    )
)
struct faceStruct
(
    numVerts,
    flags = 0,
    textureName,
    materialName
)
struct uvCoord
(
    u,
    v
)
struct selectStruct
(
    bool = 0x01,
    selName,
    numBytes
)
struct uvStruct
(
    bool = 0x01,
    tagName = "#UVSet#",
    uvSetID,
    numBytes
)
struct selNameStruct
(
    bool = 0x01,
    tagName,
    numBytes
)
struct sharpEdgeStruct
(
    bool = 0x01,
    tagName = "#SharpEdges#",
    numBytes,
    
    function getNumBytes meshColl=
    (
        numBytesq = 0
        totalEdgeArray = #()
        for i in meshColl do
        (
            vertArray = #()
            for j = 1 to i.numfaces do
            (
                smoothGroup = polyop.getFaceSmoothGroup i j
                if smoothGroup == 0 do
                (
                    edgeArray = polyop.getFaceEdges i j
                    for d in edgeArray do
                    (
                        unique = appendifunique vertArray d
                        if unique == true do numBytesq += 8
                    )
                )
            )
            append totalEdgeArray vertArray
        )
        numBytes = numBytesq
        final = #(numBytesq,totalEdgeArray)
        return final
    )
)

struct endOfFile
(
    bool = 0x01,
    tagName = "#EndOfFile#",
    bytes = 0
)
    
struct lodStruct
(
    lodType = "P3DM",
    majVer = 28,
    minVer = 256,
    numPointsLod,
    numNormalsLod,
    numFacesLod,
    unknown = 0,
    tagg = "TAGG",
    meshColl,
    resolution
)

struct vectorOp
(
    function sortCWVert obj vertIDArray faceID vertNum1=
    (
        vertArray = #()
        faceNormal = polyop.getFaceNormal obj faceID
        for i in vertIDArray do
        (
            vertPos = polyop.getvert obj (i+1-vertNum1)
            append vertArray vertPos
        )
        numVerts = vertArray.count
        center = [0,0,0]
        for i = 1 to numVerts do
        (
            center += vertArray[i]
        )
        center /= numVerts
        local a,b
        for i = 1 to numVerts-2 do
        (
            smallestAngle = -1
            smallest = -1
            a = vertArray[i]
            a -= center
            a = normalize a
            
            for j = (i +1) to numVerts do
            (
                b = vertArray[j]
                b -= center
                b = normalize b
                
                angle1 = dot a b
                if angle1 > smallestAngle do
                (
                    smallestAngle = angle1
                    smallest = j
                )
            )
            
            temp = vertIDArray[smallest]
            vertIDArray[smallest] = vertIDArray[i+1]
            vertIDArray[i+1] = temp
        )
        v1 = polyop.getvert obj (vertIDArray[1]+1-vertNum1)
        v2 = polyop.getvert obj (vertIDArray[2]+1-vertNum1)
        firstVec = v1 - center
        secondVec = v2 - center
        newNorm = normalize (cross firstVec secondVec)
        normAng = dot newNorm faceNormal
        if normAng < 0 do
        (
            reversedArray = #()
            for i=0 to numVerts-1 do
            (
                append reversedArray vertIDArray[numVerts-i]
            )
            vertIDArray = reversedArray
        )
        
        return vertIDArray
    ),
    function getVertexNormalVector obj vertexID=
    (
        listOfPolies = (polyop.getFacesUsingVert obj vertexId) as array
        listOfNormals = #()
        comPoint = [0,0,0]
        for i in listOfPolies do
        (
            polyNormal = polyop.getFaceNormal obj i
            append listOfNormals polyNormal
        )
        for j = 1 to listOfNormals.count do
        (
            comPoint += listOfNormals[j]
        )
        finalNormal = comPoint/length(comPoint)
        return finalNormal
    ),
    
    function arraySubtract coll numVerts=
    (
        coll = coll as array
        for i = 1 to coll.count do
        (
            coll[i] = coll[i]+(-1+numVerts)
        )
        return coll
    ),
    
    function getTotalNumTrisQuads meshes=
    (
        local result = [0,0]
        for i in meshes do
        (
            for j =1 to i.numfaces do
            (
                vertFaceID = (polyop.getVertsUsingFace i j) as array
                if vertFaceID.count == 3 do
                (
                    result.x += 1
                )
                if vertFaceID.count == 4 do
                (
                    result.y += 1
                )
            )
        )
        return result
    )
)

struct materialOp
(
    function getTexturePath obj =
    (
        if obj == undefined do return ""
        if obj.material == undefined do return ""
        if (Classof obj.material != PhysicalMaterial) do return ""
        if obj.material.base_color_map == undefined do return ""
        if obj.material.base_color_map.filename == undefined do return ""
        --для того что выше сделать проброс ошибок 
        return obj.material.base_color_map.filename
    ),
    function getTextureFromSubMaterial material subID =
    (
        if (Classof material == MultiMaterial) and (subID <= material.numsubs) then
        (
            subMat = material[subID]
            if (Classof subMat == PhysicalMaterial) and (subMat.base_color_map != undefined) then
            (
                return subMat.base_color_map.filename
            )
        )
        return ""
    )
)

struct arrayOp
(
    fn compareSubArrays first second =
    (
        result = true
        if first.count != second.count then result = false
        else for i = 1 to first.count do if first[i] != second[i] do result = false
        result
    )
)

vectorOps = vectorOp()
materialOps = materialOp()
arrayOps = arrayOp()

struct p3dStruct
(
    fileType = "MLOD",
    version = 257,
    noOfLods,
    selected,
    saveTex,
    saveMat,
    savePath,
    file,
    
    function sortGeo meshCollUnsorted =
    (
        meshColl = #()
        for obj in meshCollUnsorted where SuperClassOf obj == GeometryClass do append meshColl obj
        return meshColl
    ),
    function sortMem meshCollUnsorted =
    (
        meshColl = #()
        for obj in meshCollUnsorted where SuperClassOf obj == Helper do append meshColl obj
        return meshColl
    ),
    
    function writeFile =
    (
        try (
            if selected == true do noOfLods = #(#("1",0.0))
            writeString file fileType
            fseek file 4 #seek_set
            writeLong file version
            writeLong file noOfLods.count
            fseek file 12 #seek_set
            seekStartPos = 12
            for i = 1 to noOfLods.count do
            (
                if noOfLods[i][2] == 1.0e15 then memory = true else memory = false
                
                if selected == true then
                (
                    meshColl = sortGeo selection
                ) else (
                    currentLayer = (LayerManager.getLayerFromname noOfLods[i][1])
                    currentLayer.nodes &meshCollUnsorted
                    meshColl = sortGeo meshCollUnsorted
                )
                fseek file seekStartPos #seek_set
                global totalVerts = 0
                global totalPolies = 0
                if noOfLods[i][2] == 1.0e15 then
                (
                    currentLayer = (LayerManager.getLayerFromname noOfLods[i][1])
                    currentLayer.nodes &memCollUnsorted
                    memColl = sortMem memCollUnsorted
                    for point in memColl do totalVerts += 1
                ) else (
                    for i in meshColl do
                    (
                        totalVerts += i.numverts
                        totalPolies += i.numfaces
                    )
                )
                newLod = lodStruct numPointsLod:totalVerts numNormalsLod:totalVerts numFacesLod:totalPolies resolution:noOfLods[i][2]
                
                writeString file newLod.lodType
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                writeLong file newLod.majVer
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                writeLong file newLod.minVer
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                writeLong file newLod.numPointsLod
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                writeLong file newLod.numNormalsLod
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                writeLong file newLod.numFacesLod
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                writeLong file newLod.unknown
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                
                if noOfLods[i][2] != 1.0e15 then
                (
                    for expMesh in meshColl do
                    (
                        for j = 1 to expMesh.numverts do
                        (
                            fseek file seekStartPos #seek_set
                            newPoint = pointStruct()
                            newPoint.point3toPoint (polyop.getvert expMesh j)
                            writeFloat file newPoint.x
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            writeFloat file newPoint.z
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            writeFloat file newPoint.y
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            writeLong file newPoint.flags
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                        )
                    )
                ) else (
                    for point in memColl do
                    (
                        fseek file seekStartPos #seek_set
                        newPoint = pointStruct()
                        newPoint.point3toPoint point.pos
                        writeFloat file newPoint.x
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        writeFloat file newPoint.z
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        writeFloat file newPoint.y
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        writeLong file newPoint.flags
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                    )
                )
                
                if noOfLods[i][2] != 1.0e15 then
                (
                    for expMesh in meshColl do
                    (
                        for n = 1 to expMesh.numverts do
                        (
                            fseek file seekStartPos #seek_set
                            normalVector = vectorOps.getVertexNormalVector expMesh n
                            newNormal = normalStruct()
                            newNormal.point3toPoint (-normalVector)
                            writeFloat file newNormal.x
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            writeFloat file newNormal.z
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            writeFloat file newNormal.y
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                        )
                    )
                ) else (
                    for point in memColl do
                    (
                        fseek file seekStartPos #seek_set
                        newNormal = normalStruct()
                        newNormal.point3toPoint ([0,0,0])
                        writeFloat file newNormal.x
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        writeFloat file newNormal.z
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        writeFloat file newNormal.y
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                    )
                )
                
                if noOfLods[i][2] != 1.0e15 do
                (
                    numVerts1 = 0
                    for expMesh in meshColl do
                    (
                        matName = ""
                        if (Classof expMesh.material == MultiMaterial) or (Classof expMesh.material == PhysicalMaterial) then
                        (
                            if saveTex == true then
                            (
                                if (Classof expMesh.material != MultiMaterial) then
                                (
                                    texName = materialOps.getTexturePath expMesh
                                )
                            )
                            if saveMat == true then
                            (
                                messagebox "Material export not implemented yet\t"
                                return -1
                            )
                        )
                        for f = 1 to expMesh.numfaces do
                        (
                            materialID = polyop.getFaceMatID expMesh f
                            texName = ""
                            if saveTex == true do
                            (
                                case Classof expMesh.material of
                                (
                                    MultiMaterial:
                                    (
                                        texName = materialOps.getTextureFromSubMaterial expMesh.material materialID
                                    )
                                    PhysicalMaterial:
                                    (
                                        texName = materialOps.getTexturePath expMesh
                                    )
                                    default:
                                    (
                                        texName = ""
                                    )
                                )
                            )
                            vertFaceID = (polyop.getFaceVerts expMesh f) as array
                            if vertFaceID.count > 4 or vertFaceID.count < 3 do
                            (
                                messagebox "The model you are trying to export contains invalid faces. The model will not work in O2.\t"
                                return -1
                            )
                            vertIDArray = vectorOps.arraySubtract vertFaceID numVerts1
                            fseek file seekStartPos #seek_set
                            vertIDUVArray = polyop.getMapFace expMesh 1 f
                            newFace = faceStruct textureName:texName materialName:matName numVerts:vertIDArray.count
                            writeLong file newFace.numVerts
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            if (vertIDArray as array).count == 3 do (append vertIDArray (-1))
                            count = 1
                            for a in vertIDArray do
                            (
                                fseek file seekStartPos #seek_set
                                if a == -1 then
                                (
                                    newVert = vertexStruct pointID:0 normalID:0 u:0 v:0
                                ) else (
                                    newVert = vertexStruct pointID:a normalID:a u:((polyop.getMapVert expMesh 1 vertIDUVArray[count]).x) v:((polyop.getMapVert expMesh 1 vertIDUVArray[count]).y)
                                )
                                count += 1
                                writeLong file newVert.pointID
                                seekStartPos += 4
                                fseek file seekStartPos #seek_set
                                writeLong file newVert.normalID
                                seekStartPos += 4
                                fseek file seekStartPos #seek_set
                                writeFloat file newVert.u
                                seekStartPos += 4
                                fseek file seekStartPos #seek_set
                                writeFloat file newVert.v
                                seekStartPos += 4
                                fseek file seekStartPos #seek_set
                            )
                            writeLong file newFace.flags
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            writeString file newFace.textureName
                            seekStartPos += (newFace.textureName.count)
                            fseek file seekStartPos #seek_set
                            writeByte file 0x00
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                            writeString file newFace.materialName
                            seekStartPos += (newFace.materialName.count)
                            fseek file seekStartPos #seek_set
                            writeByte file 0x00
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                        )
                        numVerts1 += expMesh.numverts
                    )
                )
                
                fseek file seekStartPos #seek_set
                writeString file newLod.tagg
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                
                if noOfLods[i][2] != 1.0e15 then
                (
                    vertCount = 0
                    polyCount = 0
                    newSharp = sharpEdgeStruct()
                    sharpArray = newSharp.getNumBytes meshColl
                    numSharpBytes = sharpArray[1]
                    edgeArrays = sharpArray[2]
                    if numSharpBytes > 0 do
                    (
                        writeByte file newSharp.bool
                        seekStartPos += 1
                        fseek file seekStartPos #seek_set
                        writeString file newSharp.tagName
                        seekStartPos += newSharp.tagName.count
                        fseek file seekStartPos #seek_set
                        writeByte file 0x00
                        seekStartPos += 1
                        fseek file seekStartPos #seek_set
                        writelong file newSharp.numBytes
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        for i = 1 to edgeArrays.count do
                        (
                            objArray = edgeArrays[i]
                            for j in objArray do
                            (
                                veryIDArray = polyop.getEdgeVerts meshColl[i] j
                                for vert in veryIDArray do
                                (
                                    writeLong file (vert-1+vertCount)
                                    seekStartPos += 4
                                    fseek file seekStartPos #seek_set
                                )
                            )
                            vertCount += meshColl[i].numverts
                        )
                    )
                )
                
                if noOfLods[i][2] != 1.0e15 then
                (
                    vertCount = 0
                    polyCount = 0
                    for expMesh in meshColl do
                    (
                        newSelName = selNameStruct tagName:expMesh.name numBytes:(totalVerts+totalPolies)
                        writeByte file newSelName.bool
                        seekStartPos += 1
                        fseek file seekStartPos #seek_set
                        writeString file newSelName.tagName
                        seekStartPos += newSelName.tagName.count
                        fseek file seekStartPos #seek_set
                        writeByte file 0x00
                        seekStartPos += 1
                        fseek file seekStartPos #seek_set
                        writeLong file newSelName.numBytes
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        if vertCount > 0 do
                        (
                            for i = 1 to (vertCount) do
                            (
                                writeByte file 0x00
                                seekStartPos += 1
                                fseek file seekStartPos #seek_set
                            )
                        )
                        for i = 1 to expMesh.numverts do
                        (
                            writeByte file 0x01
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                        )
                        for i = 1 to (totalVerts-expMesh.numverts-vertCount) do
                        (
                            writeByte file 0x00
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                        )
                        if polyCount > 0 do
                        (
                            for i = 1 to (polyCount) do
                            (
                                writeByte file 0x00
                                seekStartPos += 1
                                fseek file seekStartPos #seek_set
                            )
                        )
                        for i = 1 to expMesh.numfaces do
                        (
                            writeByte file 0x01
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                        )
                        for i = 1 to (totalPolies-expMesh.numfaces-polyCount) do
                        (
                            writeByte file 0x00
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                        )
                        vertCount += expMesh.numverts
                        polyCount += expMesh.numfaces
                    )
                ) else (
                    nameArray = #()
                    for point in memColl do append nameArray point.name
                    uniqueNames = makeUniqueArray nameArray
                    for uniqueName in uniqueNames do
                    (
                        selectionTag = selNameStruct tagName:uniqueName numBytes:totalVerts
                        writeByte file selectionTag.bool
                        seekStartPos += 1
                        fseek file seekStartPos #seek_set
                        writeString file selectionTag.tagName
                        seekStartPos += selectionTag.tagName.count
                        fseek file seekStartPos #seek_set
                        writeByte file 0x00
                        seekStartPos += 1
                        fseek file seekStartPos #seek_set
                        writeLong file selectionTag.numBytes
                        seekStartPos += 4
                        fseek file seekStartPos #seek_set
                        for point in memColl do
                        (
                            if point.name == uniqueName then writeByte file 0x01 else writeByte file 0x00
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                        )
                    )
                )
                
                if noOfLods[i][2] != 1.0e15 do
                (
                    for uv = 1 to 8 do
                    (
                        nouv = false
                        try (
                            (polyop.getMapVert meshColl[1] uv 1).x
                        ) catch 
                        (
                            nouv = true
                        )
                        if (nouv == false) do
                        (
                            numBytesAllocate = vectorOps.getTotalNumTrisQuads meshColl
                            newUvSet = uvStruct numBytes:((numBytesAllocate.x*24)+(numBytesAllocate.y*32)+4) uvSetID:(uv-1)
                            writeByte file newUvSet.bool
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                            writeString file newUvSet.tagName
                            seekStartPos += newUvSet.tagName.count
                            fseek file seekStartPos #seek_set
                            writeByte file 0x00
                            seekStartPos += 1
                            fseek file seekStartPos #seek_set
                            writeLong file newUvSet.numBytes
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            writeLong file newUvSet.uvSetID
                            seekStartPos += 4
                            fseek file seekStartPos #seek_set
                            for expMesh in meshColl do
                            (
                                for f = 1 to expMesh.numfaces do
                                (
                                    vertFaceID = (polyop.getFaceVerts expMesh f) as array
                                    fseek file seekStartPos #seek_set
                                    vertIDArray = polyop.getMapFace expMesh 1 f
                                    for a in vertIDArray do
                                    (
                                        newUv = uvCoord u:((polyop.getMapVert expMesh uv (a)).x) v:(1-((polyop.getMapVert expMesh uv (a)).y))
                                        writeFloat file newUv.u
                                        seekStartPos += 4
                                        fseek file seekStartPos #seek_set
                                        writeFloat file newUv.v
                                        seekStartPos += 4
                                        fseek file seekStartPos #seek_set
                                    )
                                )
                            )
                            fseek file seekStartPos #seek_set
                        )
                    )
                )
                
                newEndOfFile = endOfFile()
                writeByte file newEndOfFile.bool
                seekStartPos += 1
                fseek file seekStartPos #seek_set
                writeString file newEndOfFile.tagName
                seekStartPos += newEndOfFile.tagName.count
                fseek file seekStartPos #seek_set
                writeByte file 0x00
                seekStartPos += 1
                fseek file seekStartPos #seek_set
                writeLong file newEndOfFile.bytes
                seekStartPos += 4
                fseek file seekStartPos #seek_set
                writeFloat file newLod.resolution
                seekStartPos += 4
                fseek file seekStartPos #seek_set
            )
            fseek file seekStartPos #seek_set
            fclose file
			messagebox "Export completed successfully\t"
			format "Debug: Export completed successfully\n"
        ) catch (
            messagebox "There was a problem with exporting, check the types of geometry you are trying to export.\t"
            fclose file
        )
    )
)