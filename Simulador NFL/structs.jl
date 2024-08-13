# mutable struct Player
#     name::String
# end

# mutable struct QB <: Player # fazer resto das posições
#     accuracy::Float64 # probabilidade de completar; poderia dividir em accuracy curta, média e longa
#     strength::Float64 # range de passes
#     vision::Float64 # capacidade de ver múltiplas rotas simultaneamente
#     pocket_presence::Float64 # fugir do sack
#     speed::Float64 # scramble
# end

# mutable struct WR <: Player
#     speed
#     route_running
#     agility
#     catching
#     contested
# end

# mutable struct CB <: Player
#     speed
#     agility
#     manIQ
#     zoneIQ
#     ball_skills
# end

# mutable struct Route
#     DoT::Float64
# end

# mutable struct Coverage
#     ManOrZone::Symbol
# end

struct PlayLog
    team::String
    yd::Int64
    down::Int64
    distance::Int64
    PassOrRun::Symbol
    Gain::Int64
end

mutable struct Team
    name::String
    players::Vector{Players}
end