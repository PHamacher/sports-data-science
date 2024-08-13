include("utils.jl")

# pff = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/pffScoutingData.csv", DataFrame)
# plays = CSV.read("Futebol/Simulador NFL/Big Data Bowl/2023/plays.csv", DataFrame)
pff = CSV.read("Big Data Bowl/2023/pffScoutingData.csv", DataFrame)
plays = CSV.read("Big Data Bowl/2023/plays.csv", DataFrame)
plays24 = CSV.read("Big Data Bowl/2024/plays.csv", DataFrame) # epa

roles = unique(pff.pff_role)
positions = unique(pff.pff_positionLinedUp)

dict_roles_per_position = Dict{String, Dict}()
for pos in positions
    dict_roles_per_position[pos] = Dict()
    df_pos = filter(x -> x.pff_positionLinedUp == pos, pff)
    [dict_roles_per_position[pos][role] = size(filter(x -> x.pff_role == role, df_pos),1)/size(df_pos,1) for role in roles]
end

def=sort(DataFrame([(k,v["Coverage"]) for (k,v) in dict_roles_per_position if v["Coverage"]+v["Pass Rush"]==1]),2)
off=sort(DataFrame([(k,v["Pass"], v["Pass Route"], v["Pass Block"]) for (k,v) in dict_roles_per_position if v["Coverage"]+v["Pass Rush"]==0]),2)

position_mapping = Dict( # desmembrar tenches (off e def)
    "QB" => "QB",
    "TE-L" => "TE",
    "LWR" => "WR",
    "HB-R" => "RB",
    "C" => "OL",
    "RWR" => "WR",
    "LEO" => "DL",
    "LT" => "OL",
    "ROLB" => "OLB",
    "LG" => "OL",
    "RCB" => "CB",
    "SLWR" => "WR",
    "SCBR" => "SC",
    "DRT" => "DL",
    "FS" => "FS",
    "RG" => "OL",
    "LILB" => "ILB",
    "RT" => "OL",
    "LCB" => "CB",
    "RE" => "DL",
    "RLB" => "LB",
    "SCBoL" => "SC",
    "SRoWR" => "WR",
    "DLT" => "DL",
    "SRiWR" => "WR",
    "SCBiL" => "SC",
    "REO" => "DL",
    "RILB" => "ILB",
    "SSR" => "SS",
    "LLB" => "LB",
    "LE" => "DL",
    "LOLB" => "OLB",
    "NLT" => "DL",
    "TE-oR" => "TE",
    "TE-iR" => "TE",
    "HB" => "RB",
    "FSR" => "FS",
    "MLB" => "LB",
    "HB-L" => "RB",
    "TE-R" => "TE",
    "SRWR" => "WR",
    "SCBL" => "SC",
    "NT" => "DL",
    "FSL" => "FS",
    "SSL" => "SS",
    "NRT" => "DL",
    "SS" => "SS",
    "SLoWR" => "WR",
    "SLiWR" => "WR",
    "SCBiR" => "SC",
    "SCBoR" => "SC",
    "TE-oL" => "TE",
    "TE-iL" => "TE",
    "FB-L" => "FB",
    "FB" => "FB",
    "FB-R" => "FB"
)



# analisar pra cada jogada a posição e função de cada jogador e avaliar o EPA
# EPA: fazer KNN com dados 2021

using NearestNeighbors

train = plays24[:, [:quarter, :down, :yardsToGo, ]]



gameId, playId = 2021090900, 97
play_data = filter(x -> x.gameId == gameId && x.playId == playId, plays)[1,:]
play_roles = filter(x -> x.gameId == gameId && x.playId == playId, pff)
epa = filter(x -> x.down)
