AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Web Screen"
ENT.Author = "Microflash"
ENT.Spawnable = true

if ( CLIENT ) then
	ENT.Mat = nil
	ENT.Panel = nil
else
	util.AddNetworkString("SetImage")
end

function ENT:SetupDataTables()
	self:NetworkVar("Int",1,"ImageX")
	self:NetworkVar("Int",2,"ImageY")
	self:NetworkVar("String",3,"ImageURL")
end

hook.Add( "PlayerSay", "PlayerSayExample", function( pl, text, team )
	-- Make the chat message entirely lowercase
	if ( string.sub( string.lower( text ), 1, 9 ) == "/setimage" ) then

		local trace = pl:GetEyeTrace()
		if trace.Entity:GetClass() == "a_urlimage" then
			net.Start("SetImage")
			net.WriteEntity(trace.Entity)
			net.WriteString(string.sub(text, 11))
			net.Broadcast()
		end
		return ""
	end
	if ( string.sub( string.lower( text ), 1, 9 ) == "/setxsize" ) then

		local trace = pl:GetEyeTrace()
		if trace.Entity:GetClass() == "a_urlimage" then
			local num = tonumber(string.sub(text, 11))
			print(num)
			trace.Entity:SetImageX(num)
		end
		return ""
	end
	if ( string.sub( string.lower( text ), 1, 9 ) == "/setysize" ) then

		local trace = pl:GetEyeTrace()
		if trace.Entity:GetClass() == "a_urlimage" then
			local num = tonumber(string.sub(text, 11))
			print(num)
			trace.Entity:SetImageY(num)
		end
		return ""
	end
end )

net.Receive("SetImage", function()
	local ent = net.ReadEntity()
	local imageurl = net.ReadString()
	print(imageurl)
	ent.Mat = nil
	ent.Panel = nil
	ent:OpenPage(imageurl)
end)

function ENT:Initialize()

	self:SetImageURL("https://puu.sh/CdksD/e704112f24.png")
	self:SetImageX(256)
	self:SetImageY(256)
	if ( SERVER ) then

		self:SetModel( "models/props_phx/rt_screen.mdl" )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:PhysicsInit( SOLID_VPHYSICS )

		self:Freeze()

	else

		-- Reset material and panel and load DHTML panel
		self.Mat = nil
		self.Panel = nil
		self:OpenPage()

	end

end

function ENT:Freeze()
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:EnableMotion( false ) end
end

-- Load the DHTML reference panel
function ENT:OpenPage(URL)

	-- Iff for some reason a panel is already loaded, delete it
	if ( self.Panel ) then

		self.Panel:Remove()
		self.Panel = nil

	end

	-- Create a web page panel and fill the entire screen
	self.Panel = vgui.Create( "DHTML" )
	self.Panel:Dock( FILL )

	-- Wiki page URL
	local ourURL = self:GetImageURL()

	if URL then
		ourURL = URL
	end

	self:SetImageURL(ourURL)
	-- Load the wiki page
	self.Panel:OpenURL( ourURL )

	-- Hide the panel
	self.Panel:SetAlpha( 0 )
	self.Panel:SetMouseInputEnabled( false )

	-- Disable HTML messages
	function self.Panel:ConsoleMessage( msg ) end

end

function ENT:Draw()

	-- Iff the material has already been grabbed from the panel
	if ( self.Mat ) then

		render.SetMaterial(self.Mat)
		render.DrawQuadEasy(self:GetPos(),self:GetAngles():Forward(),self:GetImageX(),self:GetImageY(),Color(0,0,0),180)
		-- Apply it to the screen/model
		if ( render.MaterialOverrideByIndex ) then
			render.MaterialOverrideByIndex( 1, self.Mat )
		else
			render.ModelMaterialOverride( self.Mat )
		end

	-- Otherwise, check that the panel is valid and the HTML material is finished loading
	elseif ( self.Panel && self.Panel:GetHTMLMaterial() ) then

		-- Get the html material
		local html_mat = self.Panel:GetHTMLMaterial()

		-- Used to make the material fit the model screen
		-- May need to be changed iff using a different model
		-- For the multiplication number it goes in segments of 512
		-- Based off the players screen resolution
		local scale_x, scale_y = ScrW() / 512, ScrH() / 512

		-- Create a new material with the proper scaling and shader
		local matdata =
		{
			["$basetexture"]=html_mat:GetName(),
			["$basetexturetransform"]="center 0 0 scale "..1/scale_x.." "..1/scale_y.." rotate 0 translate 0 0",
			["$model"]=1
		}

		-- Unique ID used for material name
		local uid = string.Replace( html_mat:GetName(), "__vgui_texture_", "" )

		-- Create the model material
		self.Mat = CreateMaterial( "WebMaterial_"..uid, "VertexLitGeneric", matdata )

	end

	-- Reset the material override or else everything will have a HTML material!
	render.ModelMaterialOverride( nil )

end

function ENT:OnRemove()
	-- Make sure the panel is removed too
	if ( self.Panel ) then self.Panel:Remove() end
end