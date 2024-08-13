library(worldfootballR)
# brasileirão
season <- 2023
teams <- fb_teams_urls("https://fbref.com/en/comps/24/2023/2023-Serie-A-Stats")
fb_team_player_stats(teams, stat_type = 'standard')

standard <- fb_team_player_stats(teams, stat_type= "standard")
keeper <- fb_team_player_stats(teams, stat_type= "keepers") # faltando
keeper_adv <- fb_team_player_stats(teams, stat_type= "keepers_adv") # faltando
shooting <- fb_team_player_stats(teams, stat_type= "shooting")
passing <- fb_team_player_stats(teams, stat_type= "passing")
passing_types <- fb_team_player_stats(teams, stat_type= "passing_types")
goal_shot_creation <- fb_team_player_stats(teams, stat_type= "gca")
defense <- fb_team_player_stats(teams, stat_type= "defense")
possession <- fb_team_player_stats(teams, stat_type= "possession")
playing_time <- fb_team_player_stats(teams, stat_type= "playing_time")
misc <- fb_team_player_stats(teams, stat_type= "misc")

write.csv(standard, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_standard.csv", sep=""), fileEncoding = "UTF-8")
write.csv(keeper, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_keeper.csv", sep=""), fileEncoding = "UTF-8")
write.csv(keeper_adv, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_keeper_adv.csv", sep=""), fileEncoding = "UTF-8")
write.csv(shooting, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_shooting.csv", sep=""), fileEncoding = "UTF-8")
write.csv(passing, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_passing.csv", sep=""), fileEncoding = "UTF-8")
write.csv(passing_types, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_passing_types.csv", sep=""), fileEncoding = "UTF-8")
write.csv(goal_shot_creation, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_goal_shot_creation.csv", sep=""), fileEncoding = "UTF-8")
write.csv(defense, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_defense.csv", sep=""), fileEncoding = "UTF-8")
write.csv(possession, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_possession.csv", sep=""), fileEncoding = "UTF-8")
write.csv(playing_time, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_playing_time.csv", sep=""), fileEncoding = "UTF-8")
write.csv(misc, paste("C:/Users/pedrohamacher/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirão/", season, "/player_misc.csv", sep=""), fileEncoding = "UTF-8")


mapped_players <- player_dictionary_mapping()
write.csv(mapped_players, paste("C:/Users/admin/OneDrive/Documentos antigo/Projetos_jl/Futebol/fbref data/Brasileirãomapping.csv", sep=""), fileEncoding = "UTF-8")



url_fbref <- read.csv("dados/dados2023.csv")$Url
url_tm <- mapped_players$UrlTmarkt[mapped_players$UrlFBref %in% url_fbref]

injuries <- tm_player_injury_history(player_urls = url_tm)


write.csv(injuries, "dados/injuries.csv", fileEncoding = "UTF-8")
