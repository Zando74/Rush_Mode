function RushMode:CheckQuestAchievements()
    if C_QuestLog.IsQuestFlaggedCompleted(231) then
        RushMode:SendAchievementUpdate("QUEST231")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(396) then
        RushMode:SendAchievementUpdate("QUEST396")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(19) and C_QuestLog.IsQuestFlaggedCompleted(169) then
        RushMode:SendAchievementUpdate("QUEST19")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(98) then
        RushMode:SendAchievementUpdate("QUEST98")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(55) then
        RushMode:SendAchievementUpdate("QUEST55")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(626) then
        RushMode:SendAchievementUpdate("QUEST626")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(338) then
        RushMode:SendAchievementUpdate("QUEST338")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(697) then
        RushMode:SendAchievementUpdate("QUEST697")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(5942) then
        RushMode:SendAchievementUpdate("QUEST5942")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(5944) then
        RushMode:SendAchievementUpdate("QUEST5944")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(3962) then
        RushMode:SendAchievementUpdate("QUEST3962")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(647) then
        RushMode:SendAchievementUpdate("QUEST647")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(648) then
        RushMode:SendAchievementUpdate("QUEST648")
    end
    if C_QuestLog.IsQuestFlaggedCompleted(256) then
        RushMode:SendAchievementUpdate("QUEST256")
    end
end