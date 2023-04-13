module Data

using DelimitedFiles 

struct InstanceTypeData
    instName::String
    DIMENSION:: Int
    COORD_Type::String
    EDGE_WEIGHT_FORMAT::String
end

struct InstanceData
    C
    
end

export InstanceTypeData, readTypeData, InstanceData, readDataEUC_2D, readDataGEO,  readDataCEIL_2D, readDataATT
  

function readTypeData(instanceFile::String)
    instance = readdlm(instanceFile)

    name = instance[1,2]
    dim = instance[4,2] 
    coord = instance[5,2]

    if coord == "EXPLICIT"

        weights = instance[6,2] 
    else
        weights =""  
    end
    # Print instance data
    print("Instance TYPE: Float32", 
            "\n",name,
            "\nDIMENSION: ",dim,
            "\nEDGE_WEIGHT_TYPE: ", coord,
            "\nEDGE_WEIGHT_FORMAT",weights) 

           

    instanceType = InstanceTypeData(name,dim,coord,weights)

    return instanceType

end

function readDataATT(instanceFile::String)
    instance = readdlm(instanceFile)
    
    dim = instance[4,2] 

    
    posx = Array{Float64}(undef,dim)
    posy = Array{Float64}(undef,dim)
    for i = 1:dim
        posx[i] = instance[6+i,2]
    
        posy[i] = instance[6+i,3]

    end
    
    r = Array{Float16}(undef, dim, dim)
    c = Array{Float16}(undef, dim, dim)
    for i = 1:dim
        for j = 1:dim
           
            
            r[i,j] = sqrt(((posx[i] - posx[j])^2 + (posy[i] - posy[j])^2)/10)
            if round(r[i,j], digits = 0) < r[i,j]
                c[i,j] = round(r[i,j], digits = 0) + 1
            else
                c[i,j] = round(r[i,j], digits = 0)
            end
        end
    end 
  
    println("maior valor de c",maximum(c))

           
   #=  for i = 1:dim
        for j = 1:dim
            
            println("custo C[$i,$j] = ", c[i,j])
            
        end
    end =#
    
    instance = InstanceData(c)

    return instance

end
function readDataCEIL_2D(instanceFile::String)
    instance = readdlm(instanceFile)
    dim = instance[4,2] 
   
    posx = Array{Float64}(undef,dim)
    posy = Array{Float64}(undef,dim)
    for i = 1:dim
        posx[i] = ceil(instance[6+i,2])
    
        posy[i] = ceil(instance[6+i,3])

    end
  
    c = Array{Float64}(undef, dim, dim)
    for i = 1:dim
        for j = 1:i
           
            
            c[i,j] = round(sqrt((posx[i] - posx[j])^2 + (posy[i] - posy[j])^2), digits = 0)
            
        end
    end 
   
    println("maior valor de c",maximum(c))

    #= for i = 1:dim
        for j = 1:dim
            
            println("custo C[$i,$j] = ", c[i,j])
            
        end
    end =#
  
    instance = InstanceData(c)

    return instance

end
function readDataEUC_2D(instanceFile::String)
    instance = readdlm(instanceFile)
    dim = instance[4,2] 
    posx = Array{Float32}(undef,dim)
    posy = Array{Float32}(undef,dim)
    for i = 1:dim
        posx[i] = instance[6+i,2]
    
        posy[i] = instance[6+i,3]

    end
    c = Vector{}
    c = Array{Float32}(undef, dim, dim)
    for i = 1:dim
        for j = 1:i
           
            
            c[i,j] = round(sqrt((posx[i] - posx[j])^2 + (posy[i] - posy[j])^2), digits = 0)
            
        end
    end 

    #println("\nmaior valor de c ",maximum(c))
    println("tamanho de memoria ",sizeof(c)*1e-6)
      
    #= for i = 1:dim
        for j = 1:dim
            
            println("custo C[$i,$j] = ", c[i,j])
            
        end
    end =#
    
    instance = InstanceData(c)

    return instance

end

function readDataEXPLICIT(instanceFile::String)
    instance = readdlm(instanceFile)

    format = instance[6,2]
    if format == "LOWER_DIAG_ROW"
    end
    # Print instance data
    println("Instance data: ",
            "\n"," ", format)

           

    instance = InstanceDataEXPLICIT(c)

    return instance

end


function readDataGEO(instanceFile::String)
    instance = readdlm(instanceFile)
    


    dim = instance[4,2] 
    PI = 3.141592
    posx = Array{Float64}(undef,dim)
    posy = Array{Float64}(undef,dim)
    degx = Array{Float64}(undef,dim)
    degy = Array{Float64}(undef,dim)
    minx = Array{Float64}(undef,dim)
    miny = Array{Float64}(undef,dim)
    latitude = Array{Float64}(undef,dim)
    longitude = Array{Float64}(undef,dim)
    for i = 1:dim
        posx[i] = instance[7+i,2]
        posy[i] = instance[7+i,3]
        
        degx[i] = round(posx[i], digits=0)
        degy[i] = round(posy[i], digits=0)
        minx[i] = posx[i] - degx[i]
        miny[i] = posy[i] - degy[i]
        latitude[i] = PI * (degx[i] + 5 * minx[i] / 3)/180
        longitude[i] = PI * (degy[i] + 5 * miny[i] / 3)/180

    end
    
    
    RRR = 6378.388;
    q1 = Array{Float64}(undef,dim,dim)
    q2 = Array{Float64}(undef,dim,dim)
    q3 = Array{Float64}(undef,dim,dim)
    for i = 1:dim
        for j = 1:i
        
            q1[i,j] = cos( longitude[i] - longitude[j] )
            q2[i,j]  = cos( latitude[i] - latitude[j] )
            q3[i,j]  = cos( latitude[i] + latitude[j] )
        end
    end

    c = Array{Float64}(undef, dim, dim)
    for i = 1:dim
        for j = 1:i
           
            
            c[i,j] = round(RRR * acos( 0.5 * ((1.0 + q1[i,j] ) * q2[i,j]  - (1.0 - q1[i,j] )* q3[i,j] ) ) + 1.0, digits = 0)
            
        end
    end 
     #= for i = 1:dim
        for j = 1:dim
            
            println("custo C[$i,$j] = ", c[i,j])
            
        end
    end =#
   
    instance = InstanceData(c)

    return instance

end


end
