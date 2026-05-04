local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule('Skins')

local function styleWeakAuras()
	if not T.IsAddOnLoaded("WeakAuras") or not WeakAuras then return end
	
	local function Skin_WeakAuras(frame, ftype)
		if not frame then return end

		if ftype == "icon" and frame.icon then
			if not frame.shadow then
				if E.private.KlixUI.skins.addonSkins.wa then
					frame:CreateIconShadow()
					if E.db.KlixUI.general.iconShadow and not T.IsAddOnLoaded("Masque") then
						frame.ishadow:SetInside(frame, 0, 0)
					end
				end
				frame.icon:SetTexCoord(T.unpack(E.TexCoords))
			end

			if E.private.KlixUI.skins.WAIconCooldown and frame.cooldown then
				E:RegisterCooldown(frame.cooldown)
				E:UpdateCooldownSettings('global')
			end
		end

		if ftype == "aurabar" and frame.bar and frame.icon then
			if not frame.bar.shadow then
				if E.private.KlixUI.skins.addonSkins.wa then
					frame.bar:Styling()
				end
				frame.icon:SetTexCoord(T.unpack(E.TexCoords))
			end
		end
	end

	local function HookRegionType(regionType, skinType)
		local regionTypes = WeakAuras.regionTypes
		local regionInfo = regionTypes and regionTypes[regionType]
		local create = regionInfo and regionInfo.create
		local modify = regionInfo and regionInfo.modify

		if regionInfo and regionInfo.KlixUISkinned then
			return
		end

		if type(create) ~= "function" or type(modify) ~= "function" then
			return
		end

		regionInfo.create = function(parent, data)
			local region = create(parent, data)
			Skin_WeakAuras(region, skinType)
			return region
		end

		regionInfo.modify = function(parent, region, data)
			modify(parent, region, data)
			Skin_WeakAuras(region, skinType)
		end

		regionInfo.KlixUISkinned = true
	end

	HookRegionType("icon", "icon")
	HookRegionType("aurabar", "aurabar")

	if type(WeakAuras.regions) == "table" then
		for weakAura, data in T.pairs(WeakAuras.regions) do
			if data and data.region and (data.regionType == "icon" or data.regionType == "aurabar") then
				Skin_WeakAuras(data.region, data.regionType)
			end
		end
	end
end

S:AddCallbackForAddon("WeakAuras", "KuiWeakAuras", styleWeakAuras)
