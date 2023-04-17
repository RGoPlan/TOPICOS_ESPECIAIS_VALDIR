module Data

using DelimitedFiles 

struct InstanceTypeData
    instName::String
    DIMENSION:: Int
    COORD_Type::String
    EDGE_WEIGHT_FORMAT::String
    Aux:: Int
end

struct InstanceData
    C
    
end

export InstanceTypeData, readTypeData, InstanceData, readDataXY,readDataEXPLICIT
  

function readTypeData(instanceFile::String)

    file = open(instanceFile)
    fileText = read(file, String)
    tokens = split(fileText) 
    #tokens will have all the tokens of the input 
    #file in a single vector. We will get the input token by token

 
    #instance = readdlm(instanceFile)
    
    aux = 1
    i = 1
    name  = ""
    dim = ""
    coord =""
    weights = "sem"
    while aux == 1

        if tokens[i] == "NAME:"
            name = tokens[i+1]
            
        end
        if tokens[i] == "DIMENSION:"
            dim = parse(Int,tokens[i+1])
            
        end

        if tokens[i] == "EDGE_WEIGHT_TYPE:"
            coord = tokens[i+1]
            
        end
        if coord == "EXPLICIT"
            if tokens[i] == "EDGE_WEIGHT_FORMAT:"
                weights = tokens[i+1]
                
            end
        end
        if tokens[i] == "NODE_COORD_SECTION"
            aux = i
            
        end
        i += 1
    end
    
  

    # Print instance data
    print("Instance TYPE: ", 
            "\n",name ,
            "\nDIMENSION: ",dim,
            "\nEDGE_WEIGHT_TYPE: ", coord,
            "\nEDGE_WEIGHT_FORMAT:",weights,
            "\ni= ",aux,
            "\ntamnho",length(tokens)) 

           

        datatype = InstanceTypeData(name,dim,coord,weights,aux)

    return datatype

end


function readDataXY(instanceFile::String, datatype::InstanceTypeData)

    file = open(instanceFile)
    fileText = read(file, String)
    tokens = split(fileText) 
    

    i = datatype.Aux
    j = 1
   # println("i=",i)
    dim = datatype.DIMENSION

    
    x = Array{Float32}(undef,dim)
    y = Array{Float32}(undef,dim)

    if datatype.COORD_Type == "CEIL_2D"
        while i < length(tokens)-3     
            
            x[j] = ceil(parse(Int64,tokens[i+2]) )
        
            y[j] = ceil(parse(Int64,tokens[i+3]) )
            j += 1
            i += 3   

        end
    else
        while i < length(tokens)-3   
            x[j] = parse(Float32,tokens[i+2]) 
            
            y[j] = parse(Float32,tokens[i+3]) 
            j += 1
            i += 3 
        end  
    end
   #=  for i = 1:dim
        println("valor de x[$i] = ", x[i])    
    end

    for i = 1:dim
        println("valor de y[$i] = ", y[i])    
    end =#
    if datatype.COORD_Type == "ATT"
        xd = Array{Float32}(undef,dim,dim)
        yd = Array{Float32}(undef,dim,dim)
        r = Array{Float64}(undef, dim, dim)
        c = Array{Float64}(undef, dim, dim)

        for i = 1:dim
            for j = 1:dim
                
                xd[i,j] = x[i] - x[j]
                yd[i,j] = y[i] - y[j]
                r[i,j] = sqrt((xd[i,j]^2 + yd[i,j]^2)/10)
                if round(r[i,j], digits=0) < r[i,j]
                    c[i,j] = round(r[i,j], digits=0) + 1
                else
                    c[i,j] = round(r[i,j], digits=0) 
                end
            end
        end 
  
    elseif datatype.COORD_Type == "GEO"

        PI = 3.141592
       
        degx = Array{Float64}(undef,dim)
        degy = Array{Float64}(undef,dim)
        minx = Array{Float64}(undef,dim)
        miny = Array{Float64}(undef,dim)
        latitude = Array{Float64}(undef,dim)
        longitude = Array{Float64}(undef,dim)
        for i = 1:dim
          
            
            degx[i] = round(x[i], digits=0)
            degy[i] = round(y[i], digits=0)
            minx[i] = x[i] - degx[i]
            miny[i] = y[i] - degy[i]
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
               
                
                c[i,j] = round(RRR * acos( 0.5 * ((1.0 + q1[i,j] ) * q2[i,j]  - (1.0 - q1[i,j] )* q3[i,j] ) ) + 1.0, digits=0)
                
            end
        end 
        
    else#= if datatype.COORD_Type == "EUC_2D" |"CEIL_2D" =#

        xd = Array{Float32}(undef,dim,dim)
        yd = Array{Float32}(undef,dim,dim)
        c = Array{Float64}(undef, dim, dim)

        for i = 1:dim
            for j = 1:dim
                
                xd[i,j] = x[i] - x[j]
                yd[i,j] = y[i] - y[j]
                c[i,j] = sqrt((xd[i,j]^2 + yd[i,j]^2)/10) 
            end
        end
    end
   # prinln("maior valor de c",maximum(C))
           
   #=  for i = 1:dim
        for j = 1:dim
            
            println("custo C[$i,$j] = ", c[i,j])
            
        end
    end =#
  #=   for i = 1:dim
        print("\ni_$i:")
        for j = 1:dim
           if c[i,j] > 0
                #print(" j$j = ")
                print(" ",round(c[i,j], digits=2) )
           end
            
        end
    end =#
    instance = InstanceData(c)

    return instance

end

function readDataEXPLICIT(instanceFile::String)
   
    file = open(instanceFile)
    fileText = read(file, String)
    tokens = split(fileText) 
    

    i = datatype.Aux
    j = 1

    c = Array{Float64}(undef, dim, dim)

    if datatype.EDGE_WEIGHT_FORMAT == " LOWER_DIAG_ROW"
        for k = 1:dim
            for j = 1:k

                c[k,i] = parse(Float32,tokens[i+1]) 
                i += 1
            end

            
        end

    instance = InstanceData(c)

    return instance

end





end
