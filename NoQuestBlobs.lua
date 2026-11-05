-- 1. Disable minimap quest blobs instantly on load
if Minimap then
    Minimap:SetQuestBlobOutsideAlpha(0)
    Minimap:SetQuestBlobInsideAlpha(0)
    Minimap:SetQuestBlobRingAlpha(0)
end

-- 2. Clean World Map pins only when you open it
if WorldMapFrame then
    WorldMapFrame:HookScript("OnShow", function()
        C_Timer.After(0.1, function()
            local m = WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer:GetMap()
            if m then
                m:RemoveAllPinsByTemplate("QuestBlobPinTemplate")
                m:RefreshAllDataProviders()
            end
        end)
    end)
end