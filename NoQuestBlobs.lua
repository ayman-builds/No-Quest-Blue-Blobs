-- ==========================================
-- 1. THE MINIMAP (Universal Safe Method)
-- ==========================================
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("MINIMAP_UPDATE_ZOOM")
eventFrame:RegisterEvent("QUEST_LOG_UPDATE")

local function HideMinimapBlobs()
    if not Minimap then return end

    -- Safely attempt to clear quest blob alphas across different client versions
    if Minimap.SetQuestBlobOutsideAlpha then
        pcall(function() Minimap:SetQuestBlobOutsideAlpha(0) end)
    end
    if Minimap.SetQuestBlobInsideAlpha then
        pcall(function() Minimap:SetQuestBlobInsideAlpha(0) end)
    end
    if Minimap.SetQuestBlobRingAlpha then
        pcall(function() Minimap:SetQuestBlobRingAlpha(0) end)
    end
end

eventFrame:SetScript("OnEvent", function()
    HideMinimapBlobs()
    C_Timer.After(0.2, HideMinimapBlobs)
end)

-- ==========================================
-- 2. THE WORLD MAP (Layer-Safe Hook Method)
-- ==========================================
local function HideMapBlobs()
    if not WorldMapFrame or not WorldMapFrame.ScrollContainer then return end
    
    local map = WorldMapFrame.ScrollContainer:GetMap()
    if map then
        -- Sweep active pin pool across all map layers
        if map.EnumeratePinsByTemplate then
            for pin in map:EnumeratePinsByTemplate("QuestBlobPinTemplate") do
                pin:SetAlpha(0)
            end
        end
        -- Suppress the underlying detail layer buffer during map layer transitions
        if map.detailLayer and map.detailLayer.blobFrame then
            map.detailLayer.blobFrame:SetAlpha(0)
        end
    end
end

if WorldMapFrame and WorldMapFrame.ScrollContainer then
    if WorldMapFrame.ScrollContainer.Update then
        hooksecurefunc(WorldMapFrame.ScrollContainer, "Update", HideMapBlobs)
    end
    
    WorldMapFrame:HookScript("OnShow", function()
        C_Timer.After(0.1, HideMapBlobs)
    end)

    if WorldMapFrame.RegisterCallback then
        WorldMapFrame:RegisterCallback("MapChanged", function()
            HideMapBlobs()
            C_Timer.After(0.1, HideMapBlobs)
            C_Timer.After(0.3, HideMapBlobs) -- Catches slow sub-zone layer loads
        end)
    end
end
