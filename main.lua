
function handleArguments(functionName, items)
	for index, data in pairs(items) do
		local badType = true
		local typeOrClass
		for _, typ in pairs(data.allowedTypes) do
			if typeof(data.item) == typ then
				typeOrClass = "type"
				badType = false
				break
			elseif data.class and (getmetatable(data.item).__class == typ) then
				typeOrClass = "class"
				badType = false
				break
			end
		end
		if badType then
			error("bad argument #"..index.." to '"..functionName.."' ("..data.allowedTypes[1].." expected, got "..(data.class and getmetatable(data.item)._class or type(data.item))..")", 2)
			break
		end
	end
end

function rgbToHex(r, g, b)
  local dc = "%x"
  return "0x"..dc:format(r*255)..dc:format(g*255)..dc:format(b*255)
end

local Discord = {}
local Message = {}
local Embed = {}
local Footer = {}
local Image = {}
local Thumbnail = {}
local Video = {}
local Provider = {}
local Author = {}
local Field = {}
local Webhook = {}

--// Webhook Constructor

function Discord.newWebhook(url)
	handleArguments("newWebhook", {{item = url, allowedTypes = {"string"}}})
	
	local webhook = setmetatable({}, {__index = Webhook, __class = "Webhook"})
	
	webhook.url = url
	
	return webhook
end

--// Webhook Methods

function Webhook:send(message)
	handleArguments("send", {{item = message, allowedTypes = {"Message"}, class = true}})
	
	local http = game:GetService("HttpService")	
	
	local data = {
		content = message:getContent(),
		username = message:getUsername(),
		avatar_url = message:getAvatarUrl(),
		tts = message:getTTS(),
		embeds = {}
	}
	
	print("hi")
	
	for _, embed in pairs(message:getEmbeds()) do
		local fields = {}
		for _, field in pairs(embed:getFields()) do
			table.insert(fields, {
				name = field:getName(),
				value = field:getValue(),
				inline = field:getInline()
			})
		end
		table.insert(data.embeds, {
			title = embed:getTitle(),
			description = embed:getDescription(),
			url = embed:getUrl(),
			color = embed:getColorValue(),
			footer = {text = (embed:getFooter() ~= nil and embed:getFooter():getText() or nil), icon_url = (embed:getFooter() ~= nil and embed:getFooter():getIconUrl() or nil)},
			image = {url = (embed:getImage() ~= nil and embed:getImage():getUrl() or nil)},
			thumbnail = {url = (embed:getThumbnail() ~= nil and embed:getThumbnail():getUrl() or nil)},
			video = {url = (embed:getVideo() ~= nil and embed:getVideo():getUrl() or nil)},
			provider = {name = (embed:getProvider() ~= nil and embed:getProvider():getName() or nil), url = (embed:getProvider() ~= nil and embed:getProvider():getUrl() or nil)},
			author = {name = (embed:getAuthor() ~= nil and embed:getAuthor():getName() or nil), url = (embed:getAuthor() ~= nil and embed:getAuthor():getUrl() or nil), icon_url = (embed:getAuthor() ~= nil and embed:getAuthor():getIconUrl() or nil)},
			fields = fields
		})
	end
	
	local success, err = pcall(function() http:PostAsync(self.url, http:JSONEncode(data)) end)
	
	return success, err
	
end

--// Message Constructor

function Discord.newMessage()
	local self = setmetatable({}, {__index = Message, __class = "Message"})
	
	self.content = ""
	self.username = nil
	self.avatar_url = nil
	self.tts = false
	
	self.embeds = {}
	
	return self
end

--// Message Methods

function Message:setContent(text)
	handleArguments("setContent", {{item = text, allowedTypes = {"string", "number"}}})
	self.content = tostring(text)
	return self
end

function Message:setUsername(username)
	handleArguments("setUsername", {{item = username, allowedTypes = {"string", "number"}}})
	self.username = tostring(username)
	return self
end

function Message:setAvatarUrl(avatarUrl)
	handleArguments("setAvatarUrl", {{item = avatarUrl, allowedTypes = {"string"}}})
	self.avatar_url = avatarUrl
	return self
end

function Message:setTTS(tts)
	handleArguments("setTTS", {{item = tts, allowedTypes = {"boolean"}}})
	self.tts = tts
	return self
end

function Message:getContent()
	return self.content
end

function Message:getUsername()
	return self.username
end

function Message:getAvatarUrl()
	return self.avatar_url
end

function Message:getTTS()
	return self.tts
end

function Message:getEmbeds()
	return self.embeds
end

--// Embed Constructor

function Message:addEmbed(title, description)
	handleArguments("addEmbed", {{item = title, allowedTypes = {"string", "number"}}, {item = description, allowedTypes = {"string", "number", "nil"}}})
	
	local embed = setmetatable({}, {__index = Embed, __class = "Embed"})

	embed.title = tostring(title)
	embed.description = (description == nil and nil or tostring(description))
	embed.url = nil
	embed.color = 0xffffff
	embed.footer = nil
	embed.image = nil
	embed.thumbnail = nil
	embed.video = nil
	embed.provider = nil
	embed.author = nil
	
	embed.fields = {}
	
	embed.encodedColor = Color3.new(1, 1, 1)

	self.embeds[#self.embeds + 1] = embed
	return embed	
end

----//// Embed Methods

function Embed:setTitle(title)
	handleArguments("setTitle", {{item = title, allowedTypes = {"string", "number"}}})
	self.title = tostring(title)
	return self
end

function Embed:setDescription(description)
	handleArguments("setDescription", {{item = description, allowedTypes = {"string", "number"}}})
	self.description = tostring(description)
	return self
end

function Embed:setUrl(url)
	handleArguments("setTitle", {{item = url, allowedTypes = {"string"}}})
	self.url = url
	return self
end

function Embed:setColor(color3)
	handleArguments("setColor", {{item = color3, allowedTypes = {"Color3"}}})
	self.color = tonumber(rgbToHex(color3.r, color3.g, color3.b))
	self.encodedColor = color3
	return self
end

--// Footer Constructor

function Embed:setFooter(text, iconUrl)
	handleArguments("setFooter", {{item = text, allowedTypes = {"string", "number"}}, {item = iconUrl, allowedTypes = {"string", "nil"}}})

	local footer = setmetatable({}, {__index = Footer, __class = "Footer"})
	
	footer.text = tostring(text)
	footer.icon_url = iconUrl

	self.footer = footer
	
	return footer
end

--// Footer Methods

function Footer:setText(text)
	handleArguments("setText", {{item = text, allowedTypes = {"string", "number"}}})
	self.text = tostring(text)
	return self
end

function Footer:setIconUrl(iconUrl)
	handleArguments("setIconUrl", {{item = iconUrl, allowedTypes = {"string"}}})
	self.icon_url = iconUrl
	return self
end

function Footer:getText()
	return self.text
end

function Footer:getIconUrl()
	return self.icon_url
end

--// Image Constructor

function Embed:setImage(imageUrl)
	handleArguments("setImage", {{item = imageUrl, allowedTypes = {"string"}}})
	
	local image = setmetatable({}, {__index = Image, __class = "Image"})
	
	image.url = imageUrl

	self.image = image
	
	return image	
end

--// Image Methods

function Image:setUrl(url)
	handleArguments("setUrl", {{item = url, allowedTypes = {"string"}}})
	self.url = url
	return self
end

function Image:getUrl()
	return self.url
end

--// Thumbnail Constructor

function Embed:setThumbnail(thumbnailUrl)
	handleArguments("setThumbnail", {{item = thumbnailUrl, allowedTypes = {"string"}}})
	
	local thumbnail = setmetatable({}, {__index = Thumbnail, __class = "Thumbnail"})
	
	thumbnail.url = thumbnailUrl

	self.thumbnail = thumbnail
	
	return thumbnail
end

--// Thumbnail Methods

function Thumbnail:setUrl(url)
	handleArguments("setUrl", {{item = url, allowedTypes = {"string"}}})
	self.url = url
	return self
end

function Thumbnail:getUrl()
	return self.url
end

--// Video Constructor

function Embed:setVideo(url)
	handleArguments("setVideo", {{item = url, allowedTypes = {"string"}}})
	
	local video = setmetatable({}, {__index = Video, __class = "Video"})
	
	video.url = url

	self.video = video
	
	return video
end

--// Video Methods

function Video:setUrl(url)
	handleArguments("setUrl", {{item = url, allowedTypes = {"string"}}})
	self.url = url
	return self
end

function Video:getUrl()
	return self.url
end

--// Provider Constructor

function Embed:setProvider(name, url)
	handleArguments("setProvider", {{item = name, allowedTypes = {"string", "number"}}, {item = url, allowedTypes = {"string", "nil"}}})
	
	local provider = setmetatable({}, {__index = Provider, __class = "Provider"})
	
	provider.name = tostring(name)
	provider.url = url

	self.provider = self
	
	return provider
end

--// Provider Methods

function Provider:setName(name)
	handleArguments("setName", {{item = name, allowedTypes = {"string", "number"}}})
	self.name = tostring(name)
	return self
end

function Provider:setUrl(url)
	handleArguments("setUrl", {{item = url, allowedTypes = {"string"}}})
	self.url = url
	return self
end

function Provider:getName()
	return self.name
end

function Provider:getUrl()
	return self.url
end

--// Author Constructor

function Embed:setAuthor(name, url, iconUrl)
	handleArguments("setAuthor", {{item = name, allowedTypes = {"string", "number"}}, {item = url, allowedTypes = {"string", "nil"}}})
	
	local author = setmetatable({}, {__index = Author, __class = "Author"})
	
	author.name = tostring(name)
	author.url = url
	author.icon_url = iconUrl

	self.author = author

	return author
end

--// Author Methods

function Author:setName(name)
	handleArguments("setName", {{item = name, allowedTypes = {"string", "number"}}})
	self.name = tostring(name)
	return self
end

function Author:setUrl(url)
	handleArguments("setUrl", {{item = url, allowedTypes = {"string"}}})
	self.url = url
	return self
end

function Author:setIconUrl(iconUrl)
	handleArguments("setIconUrl", {{item = iconUrl, allowedTypes = {"string"}}})
	self.icon_url = iconUrl
	return self
end

function Author:getName()
	return self.name
end

function Author:getUrl()
	return self.url
end

function Author:getIconUrl()
	return self.icon_url
end

--// Field Constructor

function Embed:addField(name, value, inline)
	handleArguments("setAuthor", {{item = name, allowedTypes = {"string", "number"}}, {item = value, allowedTypes = {"string", "number"}}, {item = inline, allowedTypes = {"boolean", "nil"}}})
	
	local field = setmetatable({}, {__index = Field, __class = "Field"})
	
	field.name = tostring(name)
	field.value = tostring(value)
	field.inline = (inline == nil and false or inline)
	
	self.fields[#self.fields + 1] = field
	
	return field
end

--// Field Methods

function Field:setName(name)
	handleArguments("setName", {{item = name, allowedTypes = {"string", "number"}}})
	self.name = tostring(name)
	return self
end

function Field:setValue(value)
	handleArguments("setValue", {{item = value, allowedTypes = {"string", "number"}}})
	self.value = tostring(value)
	return self
end

function Field:setInline(inline)
	handleArguments("setInline", {{item = inline, allowedTypes = {"boolean"}}})
	self.inline = inline
	return self
end

function Field:getName()
	return self.name
end

function Field:getValue()
	return self.value
end

function Field:getInline()
	return self.inline
end

--/

function Embed:getTitle()
	return self.title
end

function Embed:getDescription()
	return self.description
end

function Embed:getUrl()
	return self.url
end

function Embed:getColor()
	return self.encodedColor
end

function Embed:getColorValue()
	return self.color
end

function Embed:getFooter()
	return self.footer
end

function Embed:getImage()
	return self.image
end

function Embed:getThumbnail()
	return self.thumbnail
end

function Embed:getVideo()
	return self.video
end

function Embed:getProvider()
	return self.provider
end

function Embed:getAuthor()
	return self.author
end

function Embed:getFields()
	return self.fields
end

return Discord
