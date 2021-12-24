----------------------------------------------------------------------------------------------
-- Welcome to main.lua, please make yourself comfortable while reading all of this bullshit --
-- Popcorn 100g: $5 350g: $10 ----------------------------------------------------------------
-- Nachos 100g, any dip: $6 --------------------- For Saver menus, allergens, other food -----
-- Soft-Drink, any  0.5l: $4 1l: $6 -------------- and further questions please ask our ------
-- Water, sparkling or still  0.5l: $2 1l: $3 ------------------ staff -----------------------
-- Beer 0.33l: $3 ------------------------------------------ Enjoy the show! -----------------
----------------------------------------------------------------------------------------------

									---------------------
									----- VARIABLES -----
									---------------------

local game = Game()
local rplus = RegisterMod("!rpdevbuild", 1)
RepentancePlusMod = rplus
local MOD_VERSION = 1.17
local sfx = SFXManager()
local music = MusicManager()
local RNGobj = RNG()
local CustomData
local json = require("json")

--[[ for displaying achievement papers
achievement = Sprite()
achievement:Load("gfx/ui/achievement/achievements.anm2", true)
--]]

-- custom backdrop entity used for rendering sprites on the floor/walls
CustomBackDropEntity = Isaac.GetEntityVariantByName("CustomBackDropEntity")

-- helper sprites for rendering
PenIcon = Sprite()
PenIcon:Load("gfx/ui/ui_visual_clues.anm2", true)
PenIcon:Play("PenReady", false)
PenIcon.PlaybackSpeed = 0.5

SoulIcon = Sprite()
SoulIcon:Load("gfx/ui/ui_visual_clues.anm2", true)
SoulIcon:Play("SoulReady", false)
SoulIcon.PlaybackSpeed = 0.5

RedMapIcon = Sprite()
RedMapIcon:Load("gfx/ui/ui_visual_clues.anm2", true)

DNAPillIcon = Sprite()
DNAPillIcon:Load("gfx/ui/ui_dnapillhelper.anm2", true)
-------------
-- chances	
local BASEMENTKEY_CHANCE = 5			-- chance to replace golden chest with an old chest
local HEARTKEY_CHANCE = 5				-- chance for enemy to drop Flesh chest on death
local SUPERBERSERK_ENTER_CHANCE = 25	-- chance to enter berserk state via Temper Tantrum
local SUPERBERSERK_DELETE_CHANCE = 10	-- chance to erase enemies while in this state
local TRASHBAG_BREAK_CHANCE = 1			-- chance of Bag-o-Trash breaking
local CHERRY_SPAWN_CHANCE = 20			-- chance to spawn cherry on enemy death
local SLEIGHTOFHAND_UPGRADE_CHANCE = 17	-- chance to upgrade your coins via Sleight of Hand
local JACK_CHANCE = 60					-- chance for Jack cards to spawn their respective type of pickup
local TRICKPENNY_CHANCE = 17			-- chance to save your consumable when using it via Trick Penny
local CEREM_DAGGER_LAUNCH_CHANCE = 7 	-- chance to launch a dagger
local NIGHT_SOIL_CHANCE = 75 			-- chance to negate curse
local NERVEPINCH_USE_CHANCE = 80		-- chance to activate your active item for free via Nerve Pinch
local FLESHCHEST_REPLACE_CHANCE = 20	-- chance for Flesh chests to replace mimic, spiked, red chests normally
local BLACKCHEST_SPAWN_CHANCE = 20		-- chance for Black chests to spawn when entering a devil room
local SCARLETCHEST_REPLACE_CHANCE = 20	-- chance for Scarlet chests to replace any chests if any player has Red Key, Cracked Key or Crystal Key
local STARGAZER_PAYOUT_CHANCE = 15		-- chance for Stargazer beggar to payout with an item
local STARGAZER_SPAWN_CHANCE = {
	['Arcade'] = 10,
	['Planetarium'] = 75
}
local BLOODYROCKS_REPLACE_CHANCE = 30	-- chance for Bloody (Ultra secret, Tainted) rocks to replace spiked rocks

-- cooldowns
local ENRAGED_SOUL_COOLDOWN = 7 * 60		-- cooldown for Enraged Soul familiar
local REDBOMBER_LAUNCH_COOLDOWN = 1 * 60 	-- cooldown for launching red bombs
local MAGICPEN_CREEP_COOLDOWN = 4 * 60 		-- coldown for Magic Pen creep
local NERVEPINCH_HOLD = 60 * 8				-- cooldown for Nerve Pinch

									-----------------
									----- ENUMS -----
									-----------------

Costumes = {
	-- add ONLY NON-PERSISTENT COSTUMES here, because persistent costumes work without lua
	BIRDOFHOPE = Isaac.GetCostumeIdByPath("gfx/characters/costume_004_birdofhope.anm2")
}

TearVariants = {
	CEREMDAGGER = Isaac.GetEntityVariantByName("Ceremonial Dagger Tear"),
	ANTIMATERIALCARD = Isaac.GetEntityVariantByName("Antimaterial Card Tear")
}

Familiars = {
	BAGOTRASH = Isaac.GetEntityVariantByName("Bag O' Trash"),
	CHERUBIM = Isaac.GetEntityVariantByName("Cherubim"),
	CHERRY = Isaac.GetEntityVariantByName("Cherry"),
	BIRD = Isaac.GetEntityVariantByName("Bird of Hope"),
	SOUL = Isaac.GetEntityVariantByName("Enraged Soul"),
	TOYTANK1 = Isaac.GetEntityVariantByName("Toy Tank 1"),
	TOYTANK2 = Isaac.GetEntityVariantByName("Toy Tank 2"),
	SIBLING1 = Isaac.GetEntityVariantByName("Peaceful Sibling 1"),
	SIBLING2 = Isaac.GetEntityVariantByName("Peaceful Sibling 2"),
	FIGHTINGSIBLINGS = Isaac.GetEntityVariantByName("Fighting Siblings")
}

Collectibles = {
	ORDLIFE = Isaac.GetItemIdByName("Ordinary Life"),
	COOKIECUTTER = Isaac.GetItemIdByName("Cookie Cutter"),
	RUBIKSCUBE = Isaac.GetItemIdByName("Rubik's Cube"),
	MAGICCUBE = Isaac.GetItemIdByName("Magic Cube"),
	MAGICPEN = Isaac.GetItemIdByName("Magic Pen"),					
	SINNERSHEART = Isaac.GetItemIdByName("Sinner's Heart"),
	MARKCAIN = Isaac.GetItemIdByName("The Mark of Cain"),			
	BAGOTRASH = Isaac.GetItemIdByName("Bag-o-Trash"),
	TEMPERTANTRUM = Isaac.GetItemIdByName("Temper Tantrum"),
	CHERRYFRIENDS = Isaac.GetItemIdByName("Cherry Friends"),
	CHERUBIM = Isaac.GetItemIdByName("Cherubim"),
	BLACKDOLL = Isaac.GetItemIdByName("Black Doll"),
	BIRDOFHOPE = Isaac.GetItemIdByName("A Bird of Hope"),
	ENRAGEDSOUL = Isaac.GetItemIdByName("Enraged Soul"),
	CEREMDAGGER = Isaac.GetItemIdByName("Ceremonial Blade"),
	CEILINGSTARS = Isaac.GetItemIdByName("Ceiling with the Stars"),
	QUASAR = Isaac.GetItemIdByName("Quasar"),
	TWOPLUSONE = Isaac.GetItemIdByName("2+1"),
	REDMAP = Isaac.GetItemIdByName("Red Map"),
	CHEESEGRATER = Isaac.GetItemIdByName("Cheese Grater"),
	DNAREDACTOR = Isaac.GetItemIdByName("DNA Redactor"),
	TOWEROFBABEL = Isaac.GetItemIdByName("Tower of Babel"),
	BLESSOTDEAD = Isaac.GetItemIdByName("Bless of the Dead"),
	TOYTANKS = Isaac.GetItemIdByName("Tank Boys"),
	GUSTYBLOOD = Isaac.GetItemIdByName("Gusty Blood"),
	REDBOMBER = Isaac.GetItemIdByName("Red Bomber"),
	MOTHERSLOVE = Isaac.GetItemIdByName("Mother's Love"),
	CATINBOX = Isaac.GetItemIdByName("A Cat in the Box"),
	BOOKOFGENESIS = Isaac.GetItemIdByName("Book of Genesis"),
	SCALPEL = Isaac.GetItemIdByName("A Scalpel"),
	KEEPERSPENNY = Isaac.GetItemIdByName("Keeper's Penny"),
	NERVEPINCH = Isaac.GetItemIdByName("Nerve Pinch"),
	BLOODVESSELS = { 
		Isaac.GetItemIdByName("Blood Vessel"),
		Isaac.GetItemIdByName("Empty Blood Vessel"),
		Isaac.GetItemIdByName("Stained Blood Vessel"),
		Isaac.GetItemIdByName("Half Empty Blood Vessel"),
		Isaac.GetItemIdByName("Brimming Blood Vessel"),
		Isaac.GetItemIdByName("Full Blood Vessel"),
		Isaac.GetItemIdByName("Overflowing Blood Vessel") 
	},
	SIBLINGRIVALRY = Isaac.GetItemIdByName("Sibling Rivalry"),
	REDKING = Isaac.GetItemIdByName("Red King"),
	STARGAZERSHAT = Isaac.GetItemIdByName("Stargazer's Hat"),
	BOTTOMLESSBAG = Isaac.GetItemIdByName("Bottomless Bag")
}

Trinkets = {
	BASEMENTKEY = Isaac.GetTrinketIdByName("Basement Key"),
	KEYTOTHEHEART = Isaac.GetTrinketIdByName("Key to the Heart"),
	TRICKPENNY = Isaac.GetTrinketIdByName("Trick Penny"),
	JUDASKISS = Isaac.GetTrinketIdByName("Judas' Kiss"),
	SLEIGHTOFHAND = Isaac.GetTrinketIdByName("Sleight of Hand"),
	GREEDSHEART = Isaac.GetTrinketIdByName("Greed's Heart"),
	ANGELSCROWN = Isaac.GetTrinketIdByName("Angel's Crown"),
	CHALKPIECE = Isaac.GetTrinketIdByName("A Piece of Chalk"),
	MAGICSWORD = Isaac.GetTrinketIdByName("Magic Sword"),
	WAITNO = Isaac.GetTrinketIdByName("Wait, No!"),
	EDENSLOCK = Isaac.GetTrinketIdByName("Eden's Lock"),
	ADAMSRIB = Isaac.GetTrinketIdByName("Adam's Rib"),
	NIGHTSOIL = Isaac.GetTrinketIdByName("Night Soil"),
	TORNPAGE = Isaac.GetTrinketIdByName("Torn Page"),
	BONEMEAL = Isaac.GetTrinketIdByName("Bone Meal"),
	EMPTYPAGE = Isaac.GetTrinketIdByName("Empty Page"),
	BABYSHOES = Isaac.GetTrinketIdByName("Baby Shoes")
}

PocketItems = {
	RJOKER = Isaac.GetCardIdByName("Joker?"),
	SDDSHARD = Isaac.GetCardIdByName("Spindown Dice Shard"),
	REVERSECARD = Isaac.GetCardIdByName("Reverse Card"),
	REDRUNE = Isaac.GetCardIdByName("Red Rune"),
	KINGOFSPADES = Isaac.GetCardIdByName("King of Spades"),
	KINGOFCLUBS = Isaac.GetCardIdByName("King of Clubs"),
	KINGOFDIAMONDS = Isaac.GetCardIdByName("King of Diamonds"),
	NEEDLEANDTHREAD = Isaac.GetCardIdByName("Needle and Thread"),
	QUEENOFDIAMONDS = Isaac.GetCardIdByName("Queen of Diamonds"),
	QUEENOFCLUBS = Isaac.GetCardIdByName("Queen of Clubs"),
	BAGTISSUE = Isaac.GetCardIdByName("Bag Tissue"),
	LOADEDDICE = Isaac.GetCardIdByName("Loaded Dice"),
	JACKOFDIAMONDS = Isaac.GetCardIdByName("Jack of Diamonds"),
	JACKOFCLUBS = Isaac.GetCardIdByName("Jack of Clubs"),
	JACKOFSPADES = Isaac.GetCardIdByName("Jack of Spades"),
	JACKOFHEARTS = Isaac.GetCardIdByName("Jack of Hearts"),
	BEDSIDEQUEEN = Isaac.GetCardIdByName("Bedside Queen"),
	QUASARSHARD = Isaac.GetCardIdByName("Quasar Shard"),
	BUSINESSCARD = Isaac.GetCardIdByName("Business Card"),
	SACBLOOD = Isaac.GetCardIdByName("Sacrificial Blood"),
	FLYPAPER = Isaac.GetCardIdByName("Flypaper"),
	LIBRARYCARD = Isaac.GetCardIdByName("Library Card"),
	MOMSID = Isaac.GetCardIdByName("Mom's ID"),
	FUNERALSERVICES = Isaac.GetCardIdByName("Funeral Services"),
	ANTIMATERIALCARD = Isaac.GetCardIdByName("Antimaterial Card"),
	FIENDFIRE = Isaac.GetCardIdByName("Fiend Fire"),
	DEMONFORM = Isaac.GetCardIdByName("Demon Form")
}

PickUps = {
	FLESHCHEST = Isaac.GetEntityVariantByName("Flesh Chest"),
	SCARLETCHEST = Isaac.GetEntityVariantByName("Scarlet Chest"),
	BLACKCHEST = Isaac.GetEntityVariantByName("Black Chest"),
	-- tainted hearts
	TaintedHearts = {
		HEART_BROKEN  = 84,
		HEART_DAUNTLESS = 85,
		HEART_HOARDED  = 86,
		HEART_SOILED = 88,
		HEART_BENIGHTED  = 91,
		HEART_ENIGMA  = 92,
		HEART_CAPRICIOUS  = 93,
		HEART_FETTERED  = 98,
		HEART_ZEALOT = 99,
		HEART_DESERTED  = 100
	},
	SLOT_STARGAZER = Isaac.GetEntityVariantByName("Stargazer")
}

Pills = {
	ESTROGEN = Isaac.GetPillEffectByName("Estrogen Up"),
	LAXATIVE = Isaac.GetPillEffectByName("Laxative"),
	PHANTOM = Isaac.GetPillEffectByName("Phantom Pains"),
	YUM = Isaac.GetPillEffectByName("Yum!"),
	YUCK = Isaac.GetPillEffectByName("Yuck!")
}

--[[
local Unlocks = { 
	["21"] = { --T.Isaac
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.REVERSECARD}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.ORDLIFE}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = Collectibles.RUBIKSCUBE}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = Trinkets.BASEMENTKEY}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.SDDSHARD}
	},
	["22"] = { --T.Maggy
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.QUEENOFDIAMONDS}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.CHERRYFRIENDS}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.COOKIECUTTER}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = 350, SubType = Trinkets.KEYTOTHEHEART}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.NEEDLEANDTHREAD}
	},
	["23"] = { --T.Cain
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.MARKCAIN}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = 350, SubType = Trinkets.SLEIGHTOFHAND}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = 350, SubType = Trinkets.TRICKPENNY}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.BAGTISSUE}
	},
	["24"] = { --T.Judas
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.JACKOFHEARTS}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.CEREMDAGGER}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = 350, SubType = Collectibles.BLACKDOLL}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = 350, SubType = Trinkets.JUDASKISS}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.SACBLOOD}
	},
	["25"] = {	--T.???
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.FLYPAPER}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.BAGOTRASH}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["26"] = {	--T.Eve
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.BEDSIDEQUEEN}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["27"] = {	--T.Samson
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.JACKOFCLUBS}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.TEMPERTANTRUM}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["28"] = {	--T.Azazel
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["29"] = {	--T.Lazarus
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.JACKOFSPADES}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["30"] = {	--T.Eden
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["31"] = {	--T.Lost
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["32"] = {	--T.Lilith
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = PocketItems.QUEENOFCLUBS}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["33"] = {	--T.Keeper
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["34"] = {	--T.Appolyon
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.SINNERSHEART}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["35"] = {	--T.Forgor
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["36"] = {	--T.Bethany
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = Collectibles.CEILINGSTARS}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["37"] = {	--T.Jacob
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	}

}
--]]

ItemPools = {
	FLESHCHEST = { 
		15, -- <3
		16, -- Raw Liver
		36, -- Poop
		45, -- Yum Heart
		46, -- Lucky Foot
		73, -- Cube of Meat
		103, -- Common Cold
		155, -- The Peeper
		176, -- Stem Cells
		214, -- Anemic
		218, -- Placenta
		236, -- E. Coli
		254, -- Blood Clot
		273, -- Bob's Brain
		276, -- Isaac's Heart
		319, -- Cain's Other Eye
		440, -- Kidney Stone
		446, -- Dead Tooth
		452, -- Varicose Veins
		453, -- Compound Fracture
		454, -- Polydactyly
		458, -- Belly Button
		467, -- Finger
		502, -- Large Zit
		509, -- Bloodshot Eye
		525, -- Leprosy
		529, -- Pop!
		541, -- Marrow
		542, -- Slipped Rib
		544, -- Pointy Rib
		548, -- Jaw Bone
		549, -- Brittle Bones
		558, -- Eye Sore
		611, -- Larynx
		639, -- Yuck Heart
		641, -- Akeldama
		642, -- Magic Skin
		657, -- Vasculitis
		658, -- Giant Cell
		676, -- Empty Heart
		688, -- Inner Child
		695, -- Bloody Gust
		731 -- Stye
	},
	MOMNDAD = {
		175, -- Dad's Key
		102, -- Mom's Bottle of Pills
		439, -- Mom's Box
		604, -- Mom's Bracelet
		455, -- Dad's Lost Coin
		547, -- Divorce Papers
		195, -- Mom's Coin Purse
		110, -- Mom's Contacts
		55,  -- Mom's Eye
		199, -- Mom's Key
		355, -- Mom's Pearls
		228, -- Mom's Perfume
		139, -- Mom's Purse
		217, -- Mom's Wig
		546, -- Dad's Ring
		732  -- Mom's Ring (added in v1.7.5 patch)
	},
	-- not technically an itempool, but still useful
	EMPTYPAGEACTIVES = {
		130, -- pony
		136, -- best friends
		42,	 -- bob's head
		288, -- box of spiders
		160, -- crack the sky
		158, -- crystal ball
		166, -- D20
		175, -- dad's key
		85,  -- deck of cards
		291, -- flush
		145, -- guppy's head
		293, -- head of krampus
		102, -- bottle of pills
		39,  -- bra
		41,  -- pad
		37,  -- mr. boom
		77,  -- my little unicorn
		146, -- prayer card
		49,  -- shoop
		171, -- spider butt
		38,  -- tammy's head
		93,  -- gamekid
		66,  -- hourglass
		83,  -- nail
		107, -- pinking shears
		181, -- white pony
		45,  -- yum heart
		357, -- box of friends
		347, -- diplopia
		422, -- glowing hourglass
		439, -- mom's box
		521, -- coupon
		476, -- D1
		479, -- smelter
		516, -- sprinkler
		722, -- anima sola
		557, -- fortune cookie
		687, -- friend finder
		719, -- keeper's box
		650, -- plum flute
		556, -- sulfur
		605, -- the scooper
		638  -- yuck heart
	},
	BLACKCHEST = {
		CollectibleType.COLLECTIBLE_LOKIS_HORNS,
		CollectibleType.COLLECTIBLE_LUMP_OF_COAL,
		CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES,
		CollectibleType.COLLECTIBLE_GIMPY,
		CollectibleType.COLLECTIBLE_BLACK_LOTUS,
		CollectibleType.COLLECTIBLE_DARK_MATTER,
		CollectibleType.COLLECTIBLE_BLACK_CANDLE,
		CollectibleType.COLLECTIBLE_INCUBUS,
		CollectibleType.COLLECTIBLE_SUCCUBUS,
		CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN,
		CollectibleType.COLLECTIBLE_LITTLE_HORN,
		CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS,
		CollectibleType.COLLECTIBLE_LIL_ABADDON,
		CollectibleType.COLLECTIBLE_TWISTED_PAIR,
		Collectibles.BLACKDOLL,
		Collectibles.ENRAGEDSOUL
	},
	STARGAZER = {
		CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
		299,300,301,302,303,304,305,306,307,308,309,318,	-- zodiac signs
		CollectibleType.COLLECTIBLE_MAGIC_8_BALL,
		CollectibleType.COLLECTIBLE_DECK_OF_CARDS,
		588,589,590,591,592,593,594,595,596,597,598 		-- planets
	}
}

StatUps = {
	SINNERSHEART_DMG_MUL = 1.5,
	SINNERSHEART_DMG_ADD = 2,
	SINNERSHEART_SHSP = -0.2,
	SINNERSHEART_RANGE = 2, -- v1.7.5 patch fixed range (NOTE that you need to multiply it by 40 (grid length) when you apply it in MC_EVALUATE_CACHE)
	MARKCAIN_DMG = 0.66,
	LOADEDDICE_LUCK = 10,
	CEREMDAGGER_DMG_MUL = 0.9,
	SACBLOOD_DMG = 1.25,
	MAGICSWORD_DMG_MUL = 2,
	GRATER_DMG = 0.5,
	BLESS_DMG = 0.5,
	ORDLIFE_TEARS_MUL = 0.8,
	GUSTYBLOOD_SPEED = 0.07,
	GUSTYBLOOD_TEARS = 0.166,
	YUM_DAMAGE = 0.05,
	YUM_TEARS = 0.04,
	YUM_RANGE = 0.07,
	YUM_LUCK = 0.07,
	BONEMEAL_DMG_MUL = 1.1,
	MOTHERSLOVE_LUCK = 0.2,
	MOTHERSLOVE_DMG = 0.2,
	MOTHERSLOVE_TEARS = 0.1,
	MOTHERSLOVE_SPEED = 0.05,
	MOTHERSLOVE_RANGE = 0.25,
	NERVEPINCH_SPEED = -0.03,
	DEMONFORM_DAMAGE = 0.15
}

-- used by Bag Tissue
PickupWeights = {
	[PickupVariant.PICKUP_HEART] = {
		[HeartSubType.HEART_FULL] = 1,
		[HeartSubType.HEART_HALF] = 1,
		[HeartSubType.HEART_SOUL] = 4,
		[HeartSubType.HEART_ETERNAL] = 6,
		[HeartSubType.HEART_DOUBLEPACK] = 2,
		[HeartSubType.HEART_BLACK] = 5,
		[HeartSubType.HEART_GOLDEN] = 5,
		[HeartSubType.HEART_HALF_SOUL] = 4,
		[HeartSubType.HEART_SCARED] = 1,
		[HeartSubType.HEART_BLENDED] = 3,
		[HeartSubType.HEART_BONE] = 5,
		[HeartSubType.HEART_ROTTEN] = 5 
	},
	[PickupVariant.PICKUP_COIN] = { 
		[CoinSubType.COIN_PENNY] = 1,
		[CoinSubType.COIN_NICKEL] = 3,
		[CoinSubType.COIN_DIME] = 5,
		[CoinSubType.COIN_DOUBLEPACK] = 2,
		[CoinSubType.COIN_LUCKYPENNY] = 7,
		[CoinSubType.COIN_GOLDEN] = 4
	},
	[PickupVariant.PICKUP_KEY] = {
		[KeySubType.KEY_NORMAL] = 1,
		[KeySubType.KEY_GOLDEN] = 5,
		[KeySubType.KEY_DOUBLEPACK] = 2,
		[KeySubType.KEY_CHARGED] = 5
	},
	[PickupVariant.PICKUP_BOMB] = {
		[BombSubType.BOMB_NORMAL] = 2,
		[BombSubType.BOMB_DOUBLEPACK] = 4,
		[BombSubType.BOMB_GOLDEN] = 6
	},
	[PickupVariant.PICKUP_LIL_BATTERY] = {
		[BatterySubType.BATTERY_NORMAL] = 4,
		[BatterySubType.BATTERY_MICRO] = 2,
		[BatterySubType.BATTERY_MEGA] = 8,
		[BatterySubType.BATTERY_GOLDEN] = 5
	}
}

KEEPERSPENNY_ITEMPOOLS = {
	ItemPoolType.POOL_TREASURE,
	ItemPoolType.POOL_BOSS,
	ItemPoolType.POOL_SHOP
}

REDKING_BOOSROOM_IDS = {
	-- normal bossfights (bosses of main route, chapters 2 and onward)
	1031,
	1050,
	1106,
	1110,
	2020,
	2030,
	2060,
	3290,
	3310,
	3360,
	5040,
	4020,
	4030,
	4040,
	4031,
	-- double-trouble bossfights (for more fun!)
	3710, -- pin + mega fatty
	3717, -- turdlings + dangle
	3763, -- loki + lil horn
	3764, -- dark one + lil horn
	3810, -- dark one + adversary
	3812, -- fallen + lil horn
	3813, -- turdlings x2 + dangle
}

DIRECTION_FLOAT_ANIM = {
	[Direction.NO_DIRECTION] = "FloatDown", 
	[Direction.LEFT] = "FloatLeft",
	[Direction.UP] = "FloatUp",
	[Direction.RIGHT] = "FloatRight",
	[Direction.DOWN] = "FloatDown"
}

DIRECTION_SHOOT_ANIM = {
	[Direction.NO_DIRECTION] = "FloatShootDown",
	[Direction.LEFT] = "FloatShootRight",
	[Direction.UP] = "FloatShootUp",
	[Direction.RIGHT] = "FloatShootLeft",
	[Direction.DOWN] = "FloatShootDown"
}

DIRECTION_VECTOR = {
	[Direction.NO_DIRECTION] = Vector(0, 1),	-- when you don't shoot or move, you default to HeadDown
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}	

DIRECTION_VECTOR_SIMPLIFIED = {
	Vector(0, 1), 
	Vector(-1, 0), 
	Vector(0, -1), 
	Vector(1, 0)
}						
						
						----------------------
						-- HELPER FUNCTIONS --
						----------------------
--[[
-- Helpers for rendering unlock papers
local function Unlock(checkmark)
	local player = Isaac.GetPlayer(0)
	local playerType = player:GetPlayerType()
	local itemConfig = Isaac.GetItemConfig()
	
	if playerType > 20 then
		if playerType == 38 then 
			playerType = 29
		end
		if playerType == 39 then
			playerType = 37
		end
		playerType = tostring(playerType)
		if not Unlocks[playerType][checkmark].Unlocked and Unlocks[playerType][checkmark].Variant then
			Unlocks[playerType][checkmark].Unlocked = true
			local Variant = Unlocks[playerType][checkmark].Variant
			local SubType = Unlocks[playerType][checkmark].SubType
			local name
			if Variant == 100 then
				name = itemConfig:GetCollectible(SubType).Name
			elseif Variant == 300 then
				name = itemConfig:GetCard(SubType).Name
			elseif Variant == 70 then
				name = itemConfig:GetPillEffect(SubType).Name
			elseif Variant == 350 then
				name = itemConfig:GetTrinket(SubType).Name
			--elseif
				-- manual Name depending on which Pickup to choose from
			end
			
			achievement:ReplaceSpritesheet(3, "gfx/ui/achievement/achievement_" .. name .. ".png")
			achievement:LoadGraphics()
			flagRenderPaper = true
			paperRenderFrame = 0
			Isaac.SaveModData(rplus, json.encode(Unlocks, "Unlocks"))
		end
	end
end

local function RenderAchievementPapers()
	local roomCenter = room:GetCenterPos()
  	local roomTopLeft = room:GetTopLeftPos()
	local roomTypeToRenderPos = {
		[RoomShape.ROOMSHAPE_1x2] = {roomCenter.X, roomTopLeft.Y * 2},
		[RoomShape.ROOMSHAPE_1x1] = {roomCenter.X, roomCenter.Y},
		[RoomShape.ROOMSHAPE_2x2] = {roomTopLeft.X * 5.5, roomTopLeft.Y * 2}
	}
	
	pos = Isaac.WorldToRenderPosition(Vector(roomTypeToRenderPos[room:GetRoomShape()][1], roomTypeToRenderPos[room:GetRoomShape()][2]), true)
	if paperRenderFrame % 2 == 0 then
		achievement:SetFrame("Appear", paperRenderFrame / 2)
	end
	achievement:Render(pos, Vector.Zero, Vector.Zero)
	paperRenderFrame = paperRenderFrame + 1
	if paperRenderFrame >= 75 * 2 then flagRenderPaper = false end
end

function isUltraGreedRoom()
	return game.Difficulty >= 2 and game:GetRoom():GetRoomShape() == RoomShape.ROOMSHAPE_1x2 and game:GetLevel():GetStage() == LevelStage.STAGE7_GREED
end
--]]

-- Is this collectible unlocked?
local function IsCollectibleUnlocked(collectibleType)
    local isUnlocked = false
    local itemPool = game:GetItemPool()
    local player = Isaac.GetPlayer(0)
    
    player:AddCollectible(CollectibleType.COLLECTIBLE_CHAOS, 0, false)
    isUnlocked = itemPool:RemoveCollectible(collectibleType)
    player:RemoveCollectible(CollectibleType.COLLECTIBLE_CHAOS)
    
    return isUnlocked
end

local function GetUnlockedVanillaCollectible(allPools)
	allPools = allPools or false
    local ID = 0
    local itemPool = game:GetItemPool()
    local player = Isaac.GetPlayer(0)
    
    if allPools then 
		player:AddCollectible(CollectibleType.COLLECTIBLE_CHAOS, 0, false) -- makes all items appear in the list
		ID = itemPool:GetCollectible(1, false) -- gets an item without removing it from the item pool
		player:RemoveCollectible(CollectibleType.COLLECTIBLE_CHAOS) -- removes chaos
	else
		local rt = game:GetRoom():GetType()
		local ip
		
		if rt == 2 or rt == 22 then ip = 1
		elseif rt == 5 then ip = 2
		elseif rt == 7 or rt == 8 then ip = 5
		elseif rt == 10 then ip = 12
		elseif rt == 14 then ip = 3
		elseif rt == 15 or rt == 29 then ip = 4
		elseif rt == 24 then ip = 26
		else ip = 0
		end
		
		ID = itemPool:GetCollectible(ip, false)
	end
	
	return ID
end

-- Handle displaying error message advising players to restart
local function DisplayErrorMessage()
	local ErrorMessage = "Warning! Custom Mod Data of Repentance Plus #wasn't loaded, the mod could work incorrectly. #Custom Mod Data will be properly loaded next time you start a new run. #(Type 'hide' into the console or press H to hide this message)"
	if not CustomData and not hideErrorMessage then
		YOffset = 0
		for line in string.gmatch(ErrorMessage, '([^#]+)') do 
			Isaac.RenderText(line, 30, 220 + YOffset, 1, 0.2, 0.2, 1) 
			YOffset = YOffset + 12
		end
	end
end

-- Helper to give proper IV frames on revival								
local function GiveRevivalIVFrames(p)	
	-- taking fake damage
	p:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(p), 1)
	-- stopping 'hit' animation
	local Sprite = p:GetSprite()
	if Sprite:IsPlaying("Hit") then Sprite:Stop() end
	-- stopping hit sound
	if sfx:IsPlaying(SoundEffect.SOUND_ISAAC_HURT_GRUNT) then sfx:Stop(SoundEffect.SOUND_ISAAC_HURT_GRUNT) end
end														

-- Helper functions to turn fire delay into equivalent tears up (since via api only fire delay is accessible, not tears)
local function GetTears(fireDelay)
    return 30 / (fireDelay + 1)
end

local function GetFireDelay(tears)
    return math.max(30 / tears - 1, -0.9999)
end

local function isInGhostForm(player)
	return (player:GetPlayerType() == 10 or player:GetPlayerType() == 31 or
	player:GetPlayerType() == 39 or
	player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE))	-- after touching the white fire
end								

local function SilentUseCard(p, card)
	p:UseCard(card, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
end

local function isPlayerDying(player)
	-- and by 'dying' I (unfortunately) mean 'playing death animation'
	local sprite = player:GetSprite()
	
	return (sprite:IsPlaying("Death") and sprite:GetFrame() > 50) or
	(sprite:IsPlaying("LostDeath") and sprite:GetFrame() > 30)
end

local function isSelfDamage(damageFlags, data)
	-- `damageFlags` (int): damage flags passed from MC_ENTITY_TAKE_DMG callback
	-- `data` (string): can be used to specify what sources you want to include on checking (to ignore the rest)
	
	local selfDamageFlags = {
		['IVBag'] = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG,
		['Confessional'] = DamageFlag.DAMAGE_RED_HEARTS,
		['DemonBeggar'] = DamageFlag.DAMAGE_RED_HEARTS,
		['BloodDonationMachine'] = DamageFlag.DAMAGE_RED_HEARTS,
		['HellGame'] = DamageFlag.DAMAGE_RED_HEARTS,
		['CurseRoom'] = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_CURSED_DOOR,
		['MausoleumDoor'] = DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS,
		['SacrificeRoom'] = DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES
	}
	
	if data == "greedsheart" then
		selfDamageFlags = {
			selfDamageFlags['IVBag'],
			selfDamageFlags['SacrificeRoom']
		}
	elseif data == "bloodvessel" then
		selfDamageFlags = {
			selfDamageFlags['SacrificeRoom'],
			selfDamageFlags['MausoleumDoor']
		}
	elseif data == "taintedhearts" then 
		selfDamageFlags = {
			selfDamageFlags['IVBag'],
			selfDamageFlags['Confessional'],
			selfDamageFlags['DemonBeggar'],
			selfDamageFlags['BloodDonationMachine'],
			selfDamageFlags['HellGame']
		}
	end
	
	for source, flags in pairs(selfDamageFlags) do
		if damageFlags & flags == flags then
			return true
		end
	end
	return false
end

function blacklistCollectibles(player, collectible1, collectible2)
	-- `player` (EntityPlayer): a player
	-- `collectible1` (int): what collectible should be blacklisted
	-- `collectible2` (int/table): what collectible(s) should collectible1 be blacklisted from
	player = player or Isaac.GetPlayer(0)
	
	if type(collectible2) == 'number' then
		if player:HasCollectible(collectible1) then
			game:GetItemPool():RemoveCollectible(collectible2)
		end
		
		if player:HasCollectible(collectible2) then
			game:GetItemPool():RemoveCollectible(collectible1)
		end
	elseif type(collectible2) == 'table' then
		for _, COL in pairs(collectible2) do
			if player:HasCollectible(collectible1) then
				game:GetItemPool():RemoveCollectible(COL)
			end
			
			if player:HasCollectible(COL) then
				game:GetItemPool():RemoveCollectible(collectible1)
			end
		end
	end
end

function getMothersLoveStatBoost(fVariant, insertCustom, boostMul)
	-- `fVariant` (int): familiar that you want to check (you can also insert info about it if `insertCustom` is true)
	-- `insertCustom` (boolean): default - false. If true, allows you to add a custom stat boost multiplier for familiar
	-- `boostMul` (float): if you want to insert a stat boost multiplier for familiar
	
	-- for Mother's Love, familiars will grant stronger or weaker stat boosts, depending on their rarity and effectiveness
	-- all Repentance+ familiars have to be listed here
	-- all vanilla familiars unlisted do NOT grant stat boosts (e.g. spiders, flies, dips, familiar spawned from trinkets and Isaac's body parts)
	FAMILIAR_STAT_MUL = {
		[FamiliarVariant.BROTHER_BOBBY] = 1,
		[FamiliarVariant.DEMON_BABY] = 1,
		[FamiliarVariant.LITTLE_CHUBBY] = 1,
		[FamiliarVariant.LITTLE_GISH] = 1,
		[FamiliarVariant.LITTLE_STEVEN] = 1,
		[FamiliarVariant.ROBO_BABY] = 1,
		[FamiliarVariant.SISTER_MAGGY] = 1,
		[FamiliarVariant.ABEL] = 1,
		[FamiliarVariant.GHOST_BABY] = 1,
		[FamiliarVariant.HARLEQUIN_BABY] = 1,
		[FamiliarVariant.RAINBOW_BABY] = 1,
		[FamiliarVariant.DADDY_LONGLEGS] = 1,
		[FamiliarVariant.PEEPER] = 1,
		[FamiliarVariant.BOMB_BAG] = 1,
		[FamiliarVariant.SACK_OF_PENNIES] = 1,
		[FamiliarVariant.LITTLE_CHAD] = 1,
		[FamiliarVariant.RELIC] = 1.25,
		[FamiliarVariant.BUM_FRIEND] = 1,
		[FamiliarVariant.HOLY_WATER] = 1,
		[FamiliarVariant.FOREVER_ALONE] = 1,
		[FamiliarVariant.DISTANT_ADMIRATION] = 1,
		[FamiliarVariant.GUARDIAN_ANGEL] = 1,
		[FamiliarVariant.SACRIFICIAL_DAGGER] = 1,
		[FamiliarVariant.DEAD_CAT] = 1,
		[FamiliarVariant.ONE_UP] = 1.25,
		[FamiliarVariant.GUPPYS_HAIRBALL] = 1,
		[FamiliarVariant.CUBE_OF_MEAT_1] = 1,
		[FamiliarVariant.CUBE_OF_MEAT_2] = 1.25,
		[FamiliarVariant.CUBE_OF_MEAT_3] = 1.5,
		[FamiliarVariant.CUBE_OF_MEAT_4] = 1.75,
		[FamiliarVariant.SMART_FLY] = 1,
		[FamiliarVariant.DRY_BABY] = 1.25,
		[FamiliarVariant.JUICY_SACK] = 1,
		[FamiliarVariant.ROBO_BABY_2] = 1,
		[FamiliarVariant.ROTTEN_BABY] = 1,
		[FamiliarVariant.HEADLESS_BABY] = 1,
		[FamiliarVariant.LEECH] = 1,
		[FamiliarVariant.MYSTERY_SACK] = 1,
		[FamiliarVariant.BBF] = 1,
		[FamiliarVariant.BOBS_BRAIN] = 1,
		[FamiliarVariant.BEST_BUD] = 1,
		[FamiliarVariant.LIL_BRIMSTONE] = 1.25,
		[FamiliarVariant.ISAACS_HEART] = 2,
		[FamiliarVariant.LIL_HAUNT] = 1,
		[FamiliarVariant.DARK_BUM] = 1.25,
		[FamiliarVariant.BIG_FAN] = 1,
		[FamiliarVariant.SISSY_LONGLEGS] = 1,
		[FamiliarVariant.PUNCHING_BAG] = 1,
		[FamiliarVariant.BALL_OF_BANDAGES_1] = 1,
		[FamiliarVariant.BALL_OF_BANDAGES_2] = 1.25,
		[FamiliarVariant.BALL_OF_BANDAGES_3] = 1.5,
		[FamiliarVariant.BALL_OF_BANDAGES_4] = 1.75,
		[FamiliarVariant.MONGO_BABY] = 1.25,
		[FamiliarVariant.SAMSONS_CHAINS] = 1,
		[FamiliarVariant.CAINS_OTHER_EYE] = 1,
		[FamiliarVariant.BLUEBABYS_ONLY_FRIEND] = 1,
		[FamiliarVariant.GEMINI] = 1,
		[FamiliarVariant.INCUBUS] = 1.25,
		[FamiliarVariant.FATES_REWARD] = 1,
		[FamiliarVariant.LIL_CHEST] = 1,
		[FamiliarVariant.SWORN_PROTECTOR] = 1,
		[FamiliarVariant.FRIEND_ZONE] = 1,
		[FamiliarVariant.LOST_FLY] = 1,
		[FamiliarVariant.CHARGED_BABY] = 1,
		[FamiliarVariant.LIL_GURDY] = 1,
		[FamiliarVariant.BUMBO] = 1,
		[FamiliarVariant.CENSER] = 1,
		[FamiliarVariant.KEY_BUM] = 1,
		[FamiliarVariant.RUNE_BAG] = 1,
		[FamiliarVariant.SERAPHIM] = 1.25,
		[FamiliarVariant.GB_BUG] = math.random(85, 115) / 100,	-- like, glitch reference, get it guys?..
		[FamiliarVariant.SPIDER_MOD] = 1,
		[FamiliarVariant.FARTING_BABY] = 1,
		[FamiliarVariant.SUCCUBUS] = 1.25,
		[FamiliarVariant.LIL_LOKI] = 1,
		[FamiliarVariant.OBSESSED_FAN] = 1,
		[FamiliarVariant.PAPA_FLY] = 1,
		[FamiliarVariant.MILK] = 1,
		[FamiliarVariant.MULTIDIMENSIONAL_BABY] = 1,
		[FamiliarVariant.SUPER_BUM] = 3,
		[FamiliarVariant.BIG_CHUBBY] = 1,
		[FamiliarVariant.DEPRESSION] = 1,
		[FamiliarVariant.SHADE] = 1,
		[FamiliarVariant.HUSHY] = 1,
		[FamiliarVariant.LIL_MONSTRO] = 1,
		[FamiliarVariant.KING_BABY] = 1,
		[FamiliarVariant.YO_LISTEN] = 1,
		[FamiliarVariant.ACID_BABY] = 1,
		[FamiliarVariant.SPIDER_BABY] = 2,
		[FamiliarVariant.SACK_OF_SACKS] = 1,
		[FamiliarVariant.BLOODSHOT_EYE] = 1,
		[FamiliarVariant.MOMS_RAZOR] = 1,
		[FamiliarVariant.ANGRY_FLY] = 1,
		[FamiliarVariant.BUDDY_IN_A_BOX] = 1,
		[FamiliarVariant.LIL_HARBINGERS] = 1,
		[FamiliarVariant.ANGELIC_PRISM] = 1,
		[FamiliarVariant.LIL_SPEWER] = 1,
		[FamiliarVariant.SLIPPED_RIB] = 1,
		[FamiliarVariant.POINTY_RIB] = 1,
		[FamiliarVariant.HALLOWED_GROUND] = 1,
		[FamiliarVariant.JAW_BONE] = 1,
		[FamiliarVariant.INTRUDER] = 1,
		[FamiliarVariant.PSY_FLY] = 1.5,
		[FamiliarVariant.BOILED_BABY] = 1,
		[FamiliarVariant.FREEZER_BABY] = 1,
		[FamiliarVariant.LOST_SOUL] = 1.25,
		[FamiliarVariant.LIL_DUMPY] = 1,
		[FamiliarVariant.TINYTOMA] = 1,
		[FamiliarVariant.BOT_FLY] = 1,
		[FamiliarVariant.PASCHAL_CANDLE] = 1,
		[FamiliarVariant.FRUITY_PLUM] = 1,
		[FamiliarVariant.LIL_ABADDON] = 1,
		[FamiliarVariant.LIL_PORTAL] = 1,
		[FamiliarVariant.WORM_FRIEND] = 1,
		[FamiliarVariant.TWISTED_BABY] = 1,
		[FamiliarVariant.STAR_OF_BETHLEHEM] = 1,
		[FamiliarVariant.CUBE_BABY] = 1,
		[FamiliarVariant.BLOOD_PUPPY] = 1.25,
		[FamiliarVariant.VANISHING_TWIN] = 1.25,
		-- Repentance+
		[Familiars.BAGOTRASH] = 1,
		[Familiars.CHERUBIM] = 1,
		[Familiars.CHERRY] = 0,
		[Familiars.BIRD] = 0,
		[Familiars.SOUL] = 0,
		[Familiars.TOYTANK1] = 0.75,
		[Familiars.TOYTANK2] = 0.75,
		[Familiars.SIBLING1] = 0.75,
		[Familiars.SIBLING2] = 0.75,
		[Familiars.FIGHTINGSIBLINGS] = 1.5,
	}	

	insertCustom = insertCustom or false
	boostMul = boostMul or nil
	if insertCustom == true and type(boostMul) == 'number' then
		FAMILIAR_STAT_MUL[fVariant] = boostMul
		return boostMul
	end
	
	if not FAMILIAR_STAT_MUL[fVariant] then
		if fVariant < 244 or fVariant == 900 then
			-- vanilla unlisted: 0
			return 0
		else
			-- modded unlisted: 1 (unless overriden by insertCustom)
			return 1
		end
	else
		return FAMILIAR_STAT_MUL[fVariant]
	end
end

function getTrueFamiliarNum(player, collectible)
	return player:GetCollectibleNum(collectible) + player:GetEffects():GetCollectibleEffectNum(collectible)
end

local function canOpenScarletChests(player)
	return ((player:GetActiveItem(0) == CollectibleType.COLLECTIBLE_RED_KEY and player:GetActiveCharge(0) >= 4)
	or player:HasTrinket(TrinketType.TRINKET_CRYSTAL_KEY) or player:GetCard(0) == Card.CARD_CRACKED_KEY
	or player:GetCard(0) == Card.CARD_SOUL_CAIN or player:HasCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB))
end

local function openScarletChest(Pickup)
	-- subtype 1: opened chest (need to remove)
	Pickup.SubType = 1
	-- setting some data for pickup, because it is deleted on entering a new room, and the pickup is removed as well
	Pickup:GetData()["IsInRoom"] = true
	Pickup:GetSprite():Play("Open")
	sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
	RNGobj:SetSeed(Random() + 1, 1)
	local DieRoll = RNGobj:RandomFloat()
	
	if DieRoll < 0.7 then
		local ScarletChestPedestal = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Pickup.Position, Vector.Zero, Pickup)
		ScarletChestPedestal:GetSprite():ReplaceSpritesheet(5,"gfx/items/scarletchest_itemaltar.png") 
		ScarletChestPedestal:GetSprite():LoadGraphics()
		
		Pickup:Remove()
	else
		RNGobj:SetSeed(Pickup.DropSeed, 1)
		local NumOfPickups = RNGobj:RandomInt(10) + 5
		
		for i = 1, NumOfPickups do
			Isaac.Spawn(5, 30, 1, Pickup.Position, Vector.FromAngle(math.random(360)) * 5, Pickup)
		end
	end
end

local function replaceBloodyRockSprite(spikedRock, room, level)
	local stageType = level:GetStageType()
	local roomType = room:GetType()
	local stage = level:GetStage()
	if stage < 10 and stage % 2 == 0 then stage = stage - 1 end		-- no way to account for odd floors other than that, omg
	local newSpritePath
	
	if roomType == RoomType.ROOM_SECRET then
		newSpritePath = "secretroom"
	else
		local stageTypeToFilePath = {
			[LevelStage.STAGE1_1] = {	-- chapter 1
				[StageType.STAGETYPE_ORIGINAL] = "basement",
				[StageType.STAGETYPE_WOTL] = "cellar",
				[StageType.STAGETYPE_AFTERBIRTH] = "burningbasement",
				[StageType.STAGETYPE_REPENTANCE] = "downpour",
				[StageType.STAGETYPE_REPENTANCE_B] = "dross",
			},
			[LevelStage.STAGE2_1] = {	-- chapter 2
				[StageType.STAGETYPE_ORIGINAL] = "caves",
				[StageType.STAGETYPE_WOTL] = "catacombs",
				[StageType.STAGETYPE_AFTERBIRTH] = "floodedcaves",
				[StageType.STAGETYPE_REPENTANCE] = "mines",
				[StageType.STAGETYPE_REPENTANCE_B] = "ashpit",
			},
			[LevelStage.STAGE3_1] = {	-- chapter 3
				[StageType.STAGETYPE_ORIGINAL] = "depths",
				[StageType.STAGETYPE_WOTL] = "depths",
				[StageType.STAGETYPE_AFTERBIRTH] = "depths",
				[StageType.STAGETYPE_REPENTANCE] = "mausoleum",
				[StageType.STAGETYPE_REPENTANCE_B] = "gehenna",
			},
			[LevelStage.STAGE4_1] = {	-- chapter 4
				[StageType.STAGETYPE_ORIGINAL] = "womb",
				[StageType.STAGETYPE_WOTL] = "utero",
				[StageType.STAGETYPE_AFTERBIRTH] = "scarredwomb",
				[StageType.STAGETYPE_REPENTANCE] = "corpse"
			},
			[LevelStage.STAGE4_3] = "bluewomb",
			[LevelStage.STAGE5] = {	-- chapter 4
				[StageType.STAGETYPE_ORIGINAL] = "sheol",
				[StageType.STAGETYPE_WOTL] = "cathedral"
			}
		}
		
		if type(stageTypeToFilePath[stage]) == 'string' then newSpritePath = stageTypeToFilePath[stage]
		else newSpritePath = stageTypeToFilePath[stage][stageType] end
	end
	
	newSpritePath = newSpritePath or "depths"
	newSpritePath = "gfx/grid/rocks_" .. tostring(newSpritePath) .. "_alt.png"
	spikedRock:GetSprite():ReplaceSpritesheet(0, newSpritePath)
	spikedRock:GetSprite():LoadGraphics()
end
					
						-----------------------------
						-- CALLBACK TIED FUNCTIONS --
						-----------------------------

						-- MC_POST_GAME_STARTED --											
						--------------------------
function rplus:OnGameStart(Continued)
	--[[
	if Isaac.HasModData(rplus) then
		local data = Isaac.LoadModData(rplus)
		Unlocks = json.decode(data)
	else
		Isaac.SaveModData(rplus, json.encode(Unlocks, "Unlocks"))
	end
	--]]
	-- recalculating cache, just in case
	Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_ALL)
	Isaac.GetPlayer(0):EvaluateItems()
	
	-- deleting Wait, No! from trinket pool
	game:GetItemPool():RemoveTrinket(Trinkets.WAITNO)
		
	if not Continued then
		hideErrorMessage = false
		
		CustomData = {
			Items = {
				BIRDOFHOPE = {NumRevivals = 0, BirdCaught = true},
				RUBIKSCUBE = {Counter = 0},
				MARKCAIN = nil,
				BAGOTRASH = {Levels = 0},
				TEMPERTANTRUM = {ErasedEnemies = {}, SuperBerserkState = false},
				ENRAGEDSOUL = {SoulLaunchCooldown = nil, AttachedEnemy = nil},
				CEILINGSTARS = {SleptInBed = false},
				TWOPLUSONE = {ItemsBought_COINS = 0, ItemsBought_HEARTS = 0},
				CHEESEGRATER = {NumUses = 0},
				BLESSOTDEAD = {NumUses = 0},
				GUSTYBLOOD = {CurrentTears = 0, CurrentSpeed = 0},
				REDBOMBER = {BombLaunchCooldown = 0},
				MAGICPEN = {CreepSpewCooldown = nil},
				CATINBOX = {RoomEnterFrame = nil},
				BOOKOFGENESIS = {Index = 5},
				MOTHERSLOVE = {NumStats = 0, NumFriends = 0},
				BLOODVESSEL = {DamageFlag = false},
				NERVEPINCH = {Hold = 300, NumTriggers = 0},
				REDKING = {IsInRedKingRoom = false, DescendedRedCrawlspace = false, DefeatedRedKingBoss = false},
				BOTTOMLESSBAG = {UseFrame = 0, TearCount = 0, Data = false}
			},
			Cards = {
				JACK = nil,
				SACBLOOD = {Data = false, NumUses = 0},
				DEMONFORM = {NumUses = 0}
			},
			Trinkets = {
				GREEDSHEART = "CoinHeartEmpty",
				CHALKPIECE = {RoomEnterFrame = 0},
				TORNPAGE = {trinketSeen = false},
				EMPTYPAGE = {trinketSeen = false},
				BONEMEAL = {Levels = 0}
			},
			Pills = {
				LAXATIVE = {UseFrame = nil},
				YUCK = {UseFrame = -900},
				YUM = {NumLuck = 0, NumDamage = 0, NumRange = 0, NumTears = 0, UseFrame = -900},
				PHANTOM = {UseFrame = -900}
			},
			Hearts = {
				ZEALOT = 0,
				SOILED = 0,
				DAUNTLESS = 0 
			}
		}
		
		if CustomData then print("Repentance Plus mod v" .. tostring(MOD_VERSION) .. " initialized") end
		
		--[[ Spawn items/trinkets or turn on debug commands for testing here if necessary
		! DEBUG: 3 - INFINITE HP, 4 - HIGH DAMAGE, 8 - INFINITE CHARGES, 10 - INSTAKILL ENEMIES !
		
		Isaac.Spawn(5, 350, Trinkets.TestTrinket, Isaac.GetFreeNearPosition(Vector(320,280), 10.0), Vector.Zero, nil)
		Isaac.Spawn(5, 100, Collectibles.TestCollectible, Isaac.GetFreeNearPosition(Vector(320,280), 10.0), Vector.Zero, nil)
		Isaac.ExecuteCommand("debug 0")
		
		--]]
	else
		local customDataLoaded = Isaac.LoadModData(rplus)
		CustomData = json.decode(customDataLoaded)
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, rplus.OnGameStart)
						
						-- MC_PRE_GAME_EXIT --											
						----------------------
function rplus:PreGameExit(ShouldSave)
	if ShouldSave then
		Isaac.SaveModData(rplus, json.encode(CustomData, "CustomData"))
	end
	CustomData.Hearts.ZEALOT = 0 -- if player has zealot hearts before restarting or dying the game they will get wisps, so I removed all hearts before the game exists 
end
rplus:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, rplus.PreGameExit)

						-- MC_EXECUTE_CMD --											
						--------------------
function rplus:OnCommandExecute(command, args)
	if command == 'hide' then
		hideErrorMessage = true
		print('Error message hidden. To see it again, type *show* into the console')
	elseif command == 'show' then
		hideErrorMessage = false
	end
end
rplus:AddCallback(ModCallbacks.MC_EXECUTE_CMD, rplus.OnCommandExecute)

						-- MC_POST_NEW_LEVEL --										
						-----------------------
function rplus:OnNewLevel()
	local level = game:GetLevel()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if CustomData then
			CustomData.Cards.JACK = nil
			for i = 1, CustomData.Hearts.ZEALOT-math.floor(CustomData.Hearts.ZEALOT/2) do
				repeat 
					newID = GetUnlockedVanillaCollectible()
				until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
				player:AddItemWisp(newID, player.Position, true)
			end
			if player:GetData()['usedDemonForm'] then
				CustomData.Cards.DEMONFORM.NumUses = 0
				player:GetData()['usedDemonForm'] = false
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
			
			CustomData.Items.CEILINGSTARS.SleptInBed = false
			CustomData.Items.REDKING.DefeatedRedKingBoss = false
			
			if player:HasCollectible(Collectibles.BAGOTRASH) then
				CustomData.Items.BAGOTRASH.Levels = CustomData.Items.BAGOTRASH.Levels + 1
			end
		end
		
		if player:HasCollectible(Collectibles.REDMAP) then
			local USR = level:GetRoomByIdx(level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, true, RNG(), true))
			
			if USR.Data and USR.Data.Type == RoomType.ROOM_ULTRASECRET and USR.DisplayFlags & 1 << 2 == 0 then
				USR.DisplayFlags = USR.DisplayFlags | 1 << 2
				level:UpdateVisibility()
			end
		end
		
		if player:HasCollectible(Collectibles.CEILINGSTARS) then
			for i = 1, 2 do
				repeat 
					newID = GetUnlockedVanillaCollectible()
				until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
				player:AddItemWisp(newID, player.Position, true)
			end
		end
		
		if player:HasCollectible(Collectibles.TWOPLUSONE) then
			CustomData.Items.TWOPLUSONE.ItemsBought_COINS = 0
		end
		
		if player:HasTrinket(Trinkets.BONEMEAL) then
			CustomData.Trinkets.BONEMEAL.Levels = CustomData.Trinkets.BONEMEAL.Levels + 1
			player:UsePill(PillEffect.PILLEFFECT_LARGER, PillColor.PILL_NULL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		end
		
		if player:HasCollectible(Collectibles.KEEPERSPENNY) then
			Isaac.Spawn(5, 20, CoinSubType.COIN_GOLDEN, Vector(320, 320), Vector.Zero, nil)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, rplus.OnNewLevel)

						-- MC_POST_NEW_ROOM --										
						----------------------
function rplus:OnNewRoom()
	local level = game:GetLevel()
	local room = game:GetRoom()
	local roomtype = room:GetType()

	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(Collectibles.ORDLIFE) and room:GetType() == RoomType.ROOM_TREASURE 
		and room:IsFirstVisit() and not room:IsMirrorWorld() then
			momNDadItem = Isaac.Spawn(5, 100, ItemPools.MOMNDAD[math.random(#ItemPools.MOMNDAD)], room:FindFreePickupSpawnPosition(Vector(320,280), 1, true, false), Vector.Zero, nil):ToPickup()
			
			momNDadItem.OptionsPickupIndex = 3
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
					entity:ToPickup().OptionsPickupIndex = 3
				end
			end	
		end
		
		if player:HasCollectible(Collectibles.BLACKDOLL) and room:IsFirstVisit() and Isaac.CountEnemies() > 1 then
			ABSepNumber = math.floor(Isaac.CountEnemies() / 2)
			EntitiesGroupA = {}
			EntitiesGroupB = {}
			local Count = 0
			
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:IsActiveEnemy(false) and not entity:IsBoss() then
					Count = Count + 1
					if Count <= ABSepNumber then
						table.insert(EntitiesGroupA, entity)
					else
						table.insert(EntitiesGroupB, entity)
					end
				end
			end
		end
		
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 3 and entity.Variant == Familiars.SOUL then
				entity:Remove()
			end
		end
		
		if player:HasTrinket(Trinkets.ANGELSCROWN) and roomtype == RoomType.ROOM_TREASURE 
		and not room:IsMirrorWorld() then
			if room:IsFirstVisit() then
				for _, collectible in pairs(Isaac.FindByType(5, 100, -1, false, false)) do
					collectiblePickup = collectible:ToPickup()
					collectiblePickup:Morph(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ANGEL, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), false, false, false)
					collectiblePickup.Price = 15
					collectiblePickup.ShopItemId = -777
				end
			end
			
			for i = 1, room:GetGridSize() do
				if room:GetGridEntity(i) ~= nil 
				and room:GetGridEntity(i):GetType() ~= GridEntityType.GRID_DOOR and room:GetGridEntity(i):GetType() ~= GridEntityType.GRID_WALL then
					room:RemoveGridEntity(i, 0, false)
				end
			end
			
			if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x1 then
				AngelPos = Vector(320, 200)
				FloorPos = Vector(60, 140)
				WallPos = Vector(-20, 60)
			elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IH then
				AngelPos = Vector(320, 240)
				FloorPos = Vector(60, 220)
				WallPos = Vector(-20, 138)
			elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IV then
				AngelPos = Vector(320, 200)
				FloorPos = Vector(220, 140)
				WallPos = Vector(145, 60)
			end
			Isaac.GridSpawn(GridEntityType.GRID_STATUE, 1, AngelPos, false)
			FloorPiece = Isaac.Spawn(1000, CustomBackDropEntity, 0, FloorPos, Vector.Zero, nil)
			WallPiece = Isaac.Spawn(1000, CustomBackDropEntity, 0, WallPos, Vector.Zero, nil)
		end 
		
		if player:HasTrinket(Trinkets.CHALKPIECE) and not room:IsClear() and room:IsFirstVisit() then
			CustomData.Trinkets.CHALKPIECE.RoomEnterFrame = game:GetFrameCount()
		end
		
		if player:HasCollectible(Collectibles.TWOPLUSONE) and CustomData then
			CustomData.Items.TWOPLUSONE.ItemsBought_HEARTS = 0
			if CustomData.Items.TWOPLUSONE.ItemsBought_COINS == 0 then
				for _, pickup in pairs(Isaac.FindByType(5, -1, -1, false, false)) do
					if pickup:ToPickup().Price == 1 then
						pickup:ToPickup().AutoUpdatePrice = true
					end
				end
			end
		end
		
		if player:HasCollectible(Collectibles.GUSTYBLOOD) then
			CustomData.Items.GUSTYBLOOD.CurrentTears = 0
			CustomData.Items.GUSTYBLOOD.CurrentSpeed = 0
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
		end
		
		if player:GetData()['usedLoadedDice'] then
			player:GetData()['usedLoadedDice'] = false
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
		
		if player:HasCollectible(Collectibles.TOYTANKS) then
			tankData[Familiars.TOYTANK1].newRoomCurrHold = game:GetFrameCount()
			tankData[Familiars.TOYTANK2].newRoomCurrHold = game:GetFrameCount()
		end
		
		if player:HasCollectible(Collectibles.CATINBOX) and not room:IsClear() then
			CustomData.Items.CATINBOX.RoomEnterFrame = game:GetFrameCount()
			for _, enemy in pairs(Isaac.GetRoomEntities()) do
				if enemy:IsVulnerableEnemy() and not enemy:IsBoss() then 
					enemy:TakeDamage(math.ceil(enemy.MaxHitPoints / 2), 1, EntityRef(player), 0) 
				end
			end
		end
		
		if player:HasCollectible(Collectibles.KEEPERSPENNY) and room:GetType() == RoomType.ROOM_SHOP 
		and room:IsFirstVisit() and not room:IsMirrorWorld() and #Isaac.FindByType(EntityType.ENTITY_GREED, -1, -1, false, true) == 0 then
			RNGobj:SetSeed(Random() + 1, 1)
			local numNewItems = RNGobj:RandomInt(3) + 1
			
			if numNewItems == 1 then
				V = {Vector(320, 280)}
			elseif numNewItems == 2 then
				V = {Vector(160, 280), Vector(480, 280)}
			elseif numNewItems == 3 then
				V = {Vector(320, 280), Vector(160, 280), Vector(480, 280)}
			else
				V = {Vector(160, 280), Vector(480, 280), Vector(120, 360), Vector(520, 360)}
			end
			
			for i = 1, numNewItems do
				local pool = KEEPERSPENNY_ITEMPOOLS[math.random(#KEEPERSPENNY_ITEMPOOLS)]
				local Item = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(pool, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), V[i], Vector.Zero, nil):ToPickup()
				Item.Price = 15
				Item.ShopItemId = -11 * i
			end
		end
		
		if player:HasTrinket(Trinkets.TORNPAGE) then
			if player:GetData()['enhancedBoB'] then				
				player:GetData()['enhancedBoB'] = false
				player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
				player:EvaluateItems()
			end		
		end
	
		if player:GetData()['usedDemonForm'] 
		and not room:IsClear() and room:IsFirstVisit() then
			CustomData.Cards.DEMONFORM.NumUses = CustomData.Cards.DEMONFORM.NumUses + 1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
		
		if CustomData then
			CustomData.Items.REDKING.IsInRedKingRoom = false
			if CustomData.Items.REDKING.DescendedRedCrawlspace then
				CustomData.Items.REDKING.IsInRedKingRoom = true
				CustomData.Items.REDKING.DescendedRedCrawlspace = false
			end
			if CustomData.Items.REDKING.DefeatedRedKingBoss then
				for _, redTrapdoor in pairs(Isaac.FindByType(6, 334, -1, false, false)) do
					redTrapdoor:GetSprite():Play("Closed")
					redTrapdoor.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				end
			end
		end
	end
	
	if room:GetType() == RoomType.ROOM_LIBRARY
	and room:IsFirstVisit() then
		RNGobj:SetSeed(Random() + 1, 1)
		local pageSpawnRoll = math.ceil(RNGobj:RandomFloat() * 100)
		
		if pageSpawnRoll < 33 and not CustomData.Trinkets.TORNPAGE.trinketSeen then
			Isaac.Spawn(5, 350, Trinkets.TORNPAGE, Isaac.GetFreeNearPosition(Vector(320, 280), 10), Vector.Zero, nil)
			CustomData.Trinkets.TORNPAGE.trinketSeen = true
		elseif pageSpawnRoll < 66 and not CustomData.Trinkets.EMPTYPAGE.trinketSeen then
			Isaac.Spawn(5, 350, Trinkets.EMPTYPAGE, Isaac.GetFreeNearPosition(Vector(320, 280), 10), Vector.Zero, nil)
			CustomData.Trinkets.EMPTYPAGE.trinketSeen = true
		end
	end
	
	if room:GetType() == RoomType.ROOM_DEVIL
	and room:IsFirstVisit()	and #Isaac.FindByType(EntityType.ENTITY_FALLEN, 1, 0, false, true) == 0
	and math.random(100) < BLACKCHEST_SPAWN_CHANCE then
		Isaac.Spawn(5, PickUps.BLACKCHEST, 0, Isaac.GetFreeNearPosition(Vector(440, 240), 10), Vector.Zero, nil)
		Isaac.Spawn(5, PickUps.BLACKCHEST, 0, Isaac.GetFreeNearPosition(Vector(200, 240), 10), Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
	end
	
	if room:GetType() == RoomType.ROOM_PLANETARIUM
	and room:IsFirstVisit() and math.random(100) < STARGAZER_SPAWN_CHANCE["Planetarium"] then
		Isaac.Spawn(6, PickUps.SLOT_STARGAZER, 0, Isaac.GetFreeNearPosition(Vector(200, 240), 10), Vector.Zero, nil)
	end
	if room:GetType() == RoomType.ROOM_ARCADE and room:IsFirstVisit() then
		for _, beggar in pairs(Isaac.FindByType(6, -1, -1, false, false)) do
			if (beggar.Variant == 9 or beggar.Variant == 7 or beggar.Variant == 4 or beggar.Variant == 5 or beggar.Variant == 13)
			and math.random(100) < STARGAZER_SPAWN_CHANCE["Arcade"] then
				beggar:Remove()
				Isaac.Spawn(6, PickUps.SLOT_STARGAZER, 0, beggar.Position, Vector.Zero, nil)
				break
			end
		end
	end
	
	-- bloody rocks
	if level:GetStage() ~= LevelStage.STAGE7 then
		for ind = 1, room:GetGridSize() do
			local gridEnt = room:GetGridEntity(ind)
			
			if gridEnt and gridEnt:GetType() == GridEntityType.GRID_ROCK_SPIKED then				
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomFloat() * 100
				
				if (roll < BLOODYROCKS_REPLACE_CHANCE and room:IsFirstVisit() or gridEnt:GetVariant() == 2) then
					gridEnt:SetVariant(2)
					replaceBloodyRockSprite(gridEnt, room, level)
				end
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, rplus.OnNewRoom)

						-- MC_POST_UPDATE --											
						--------------------
function rplus:OnFrame()
	local room = game:GetRoom()
	local level = game:GetLevel()
	local stage = level:GetStage()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local sprite = player:GetSprite()
		
		-- it turns out that more and more items 
		-- behave in unintentional ways together, 
		-- so let's BLACKLIST THEM HERE ---------
		-----------------------------------------
		
		-- there's just no nice synergy yet, it looks wacky
		blacklistCollectibles(player, Collectibles.REDBOMBER, CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR)
		
		-- some differently colored pills have same effects with PHD/False PHD, and since the MC_USE_PILL asks for pill effect, there's no way to distinguish
		-- them and apply the DNA redactor effect correctly
		blacklistCollectibles(player, Collectibles.DNAREDACTOR, {CollectibleType.COLLECTIBLE_PHD, CollectibleType.COLLECTIBLE_FALSE_PHD})
		-----------------------------------------
		
		-- helper for telling ID of the sound that I want (I'm fucking tired)
		--for i = 1, 817 do
		--	if sfx:IsPlaying(i) then print(i) end
		--end		
		
		if player:GetData()['reverseCardRoom'] and player:GetData()['reverseCardRoom'] ~= game:GetLevel():GetCurrentRoomIndex() then
			player:AnimateCard(PocketItems.REVERSECARD, "Pickup")
			local secondaryCard = player:GetCard(1)
			player:SetCard(1, 0)
			player:SetCard(0, secondaryCard)
			player:GetData()['reverseCardRoom'] = nil
		end
		
		if player:HasCollectible(Collectibles.MAGICPEN) then
			-- taste the rainbow
			for _, entity in pairs(Isaac.FindByType(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 4, true, false)) do
				local Frame = game:GetFrameCount() % 490 + 1
				
				if Frame <= 140 then
					entity:SetColor(Color(1, Frame / 140, 0), 1, 1, false, false)
				elseif Frame <= 210 then
					entity:SetColor(Color(1 - (Frame - 140) / 70, 1, 0), 1, 1, false, false)
				elseif Frame <= 280 then
					entity:SetColor(Color(0, 1 - (Frame - 210) / 70, (Frame - 210) / 70), 1, 1, false, false)
				elseif Frame <= 350 then
					entity:SetColor(Color((Frame - 280) / 70 * 75 / 255, 0, (Frame - 280) / 70 * 130 / 255), 1, 1, false, false)
				elseif Frame <= 420 then
					entity:SetColor(Color((75 + (Frame - 350) / 70 * 58) / 255, 0, (130 + (Frame - 350) / 70 * 125) / 255), 1, 1, false, false)
				else
					entity:SetColor(Color((143 + (Frame - 420) / 70 * 112) / 255, 0, 1 - (Frame - 420) / 70), 1, 1, false, false)
				end
			end
		end
		
		if player:HasCollectible(Collectibles.MARKCAIN) 
		and player:GetExtraLives() == 0 then
			if isPlayerDying(player) then
				MyFamiliars = {}
				
				for i = 1, 1000 do
					if Isaac.GetItemConfig():GetCollectible(i) and Isaac.GetItemConfig():GetCollectible(i).Type == ItemType.ITEM_FAMILIAR and player:HasCollectible(i) then
						for j = 1, player:GetCollectibleNum(i, true) do
							table.insert(MyFamiliars, i)
						end
					end
				end
				if #MyFamiliars > 0 then
					player:RemoveCollectible(Collectibles.MARKCAIN)
					for i = 0, game:GetNumPlayers() - 1 do
						Isaac.GetPlayer(i):Revive()
						GiveRevivalIVFrames(Isaac.GetPlayer(i))
					end
					
					CustomData.Items.MARKCAIN = "player revived"
					sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, 1, 0)
					
					for i = 1, #MyFamiliars do player:RemoveCollectible(MyFamiliars[i]) end
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()
				end
			end
		end
		
		if player:HasCollectible(Collectibles.TEMPERTANTRUM) or player:GetData()['pillInvokedSuperBerserkState'] == true then
			if CustomData.Items.TEMPERTANTRUM.SuperBerserkState and sfx:IsPlaying(SoundEffect.SOUND_BERSERK_END) then 
				CustomData.Items.TEMPERTANTRUM.SuperBerserkState = false
				player:GetData()['pillInvokedSuperBerserkState'] = nil
			end
		end
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity:IsActiveEnemy() and CustomData.Items.TEMPERTANTRUM.ErasedEnemies then
				for i = 1, #CustomData.Items.TEMPERTANTRUM.ErasedEnemies do
					if entity.Type == CustomData.Items.TEMPERTANTRUM.ErasedEnemies[i] then
						Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
						entity:Remove()
					end
				end
			end
		end
		
		if player:HasCollectible(Collectibles.CHERRYFRIENDS) and room:IsClear() then
			for _, cherry in pairs(Isaac.FindByType(3, Familiars.CHERRY, -1, true, false)) do
				cherry:GetSprite():Play("Collect")
				if cherry:GetSprite():IsFinished("Collect") then
					cherry:Remove()
					Isaac.Spawn(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, cherry.Position, Vector.Zero, nil)
				end
			end
		end
		
		if player:HasCollectible(Collectibles.BIRDOFHOPE) then
			if isPlayerDying(player)
			and CustomData.Items.BIRDOFHOPE.BirdCaught == true then
				CustomData.Items.BIRDOFHOPE.BirdCaught = false
				DieFrame = game:GetFrameCount()
				DiePos = player.Position
				CustomData.Items.BIRDOFHOPE.NumRevivals = CustomData.Items.BIRDOFHOPE.NumRevivals + 1
				
				player:GetData()['catchingBird'] = true
				player:Revive()
				sprite:Stop()
				player:AddCacheFlags(CacheFlag.CACHE_FLYING)
				player:EvaluateItems()
				player:AddNullCostume(Costumes.BIRDOFHOPE)
				
				Birdy = Isaac.Spawn(3, Familiars.BIRD, 0, room:GetCenterPos(), Vector.FromAngle(math.random(360)) * CustomData.Items.BIRDOFHOPE.NumRevivals, nil) 
				Birdy:GetSprite():Play("Flying")
			elseif DieFrame and game:GetFrameCount() > DieFrame + 120 and not CustomData.Items.BIRDOFHOPE.BirdCaught then
				player:Die()
				CustomData.Items.BIRDOFHOPE.BirdCaught = "blah blah"	-- just so that it's not true and player doesn't die over and over 
				-- until all his extra lives are depleted
				-- !!! THIS IS A SERIOUS CROTCH !!! since you end up near the door when reviving, and the bird familiar doesn't despawn if you don't catch her,
				-- you automatically pick her up and this allows you to repeat the cycle (since it switches data to true) and doesn't take away your extra lives
				-- so don't touch it if you don't think it through. like, for real.
			end
		end
		
		if player:HasTrinket(Trinkets.CHALKPIECE) and CustomData then
			if CustomData.Trinkets.CHALKPIECE.RoomEnterFrame 
			and game:GetFrameCount() <= CustomData.Trinkets.CHALKPIECE.RoomEnterFrame + 150 
			and game:GetFrameCount() % 2 == 0 then
				local Powder = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 5, player.Position, Vector.Zero, nil):ToEffect()
				
				Powder:GetSprite():Load("gfx/1000.333_effect_chalk_powder.anm2", true)
				Powder.Timeout = 600
				Powder:SetColor(Color(1, 1, 1, 1, 0, 0, 0), 610, 1, true, false)
				Powder:Update()
			end
		end
		
		if CustomData and CustomData.Cards.SACBLOOD.Data then
			if game:GetFrameCount() % math.floor(1 + 11 / CustomData.Cards.SACBLOOD.NumUses) == 0 then
				Step = Step + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
				if Step == 50 * CustomData.Cards.SACBLOOD.NumUses then 
					CustomData.Cards.SACBLOOD.Data = false 
					CustomData.Cards.SACBLOOD.NumUses = 0
				end
			end
		end
		
		if player:HasTrinket(Trinkets.ADAMSRIB) then
			if isPlayerDying(player) then
				player:TryRemoveTrinket(Trinkets.ADAMSRIB)
				for i = 0, game:GetNumPlayers() - 1 do
					Isaac.GetPlayer(i):Revive()
					GiveRevivalIVFrames(Isaac.GetPlayer(i))
				end
				player:ChangePlayerType(PlayerType.PLAYER_EVE)
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then player:AddCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) end
				player:AddMaxHearts(-24, false)
				player:AddSoulHearts(6)
			end
		end
		
		if player:HasCollectible(Collectibles.TWOPLUSONE) then
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 then
					EntPickup = entity:ToPickup()
					if EntPickup.Price > 0 and CustomData.Items.TWOPLUSONE.ItemsBought_COINS == 2  then
						EntPickup.Price = 1
						EntPickup.AutoUpdatePrice = false
					elseif EntPickup.Price > -1000 and EntPickup.Price < 0 and CustomData.Items.TWOPLUSONE.ItemsBought_HEARTS == 2  then
						EntPickup.Price = 0
					end
				end
			end
		end
		
		if CustomData and CustomData.Pills.LAXATIVE.UseFrame and game:GetFrameCount() % 4 == 0 then
			if (game:GetFrameCount() <= CustomData.Pills.LAXATIVE.UseFrame + 90 and player:GetData()['usedLax'])
			or (game:GetFrameCount() <= CustomData.Pills.LAXATIVE.UseFrame + 360 and player:GetData()['usedHorseLax']) then
				local vector = Vector.FromAngle(DIRECTION_VECTOR[player:GetMovementDirection()]:GetAngleDegrees() + math.random(-15, 15)):Resized(-7.5)
				local SCorn = Isaac.Spawn(2, 0, 0, player.Position, vector, nil):GetSprite()
				
				SCorn:Load("gfx/002.122_corn_tear.anm2", true)
				SCorn:Play("Big0" .. math.random(4))
				cornScale = math.random(5, 10) / 10
				SCorn.Scale = Vector(cornScale, cornScale)
			else
				CustomData.Pills.LAXATIVE.UseFrame = nil
				player:GetData()['usedLax'] = false
				player:GetData()['usedHorseLax'] = false
			end
		end
		
		if player:HasCollectible(Collectibles.REDMAP) and not room:IsFirstVisit() 
		and room:GetType() < 6 and room:GetType() > 3 then
			for _, trinket in pairs(Isaac.FindByType(5, 350, -1, false, false)) do
				trinket:ToPickup():Morph(5, 300, Card.CARD_CRACKED_KEY, true, true, true)
			end
		end
		
		if CustomData and CustomData.Pills.PHANTOM.UseFrame and (game:GetFrameCount() - CustomData.Pills.PHANTOM.UseFrame) % 600 == 1 then
			if game:GetFrameCount() <= CustomData.Pills.PHANTOM.UseFrame + 1300 
			and not isInGhostForm(player)
			and (player:GetData()['usedPhantom'] or player:GetData()['usedHorsePhantom']) then
				player:TakeDamage(1, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 24)
				if player:GetData()['usedHorsePhantom'] then
					for angle = 0, 360, 45 do
						local boneTear = player:FireTear(player.Position, Vector.FromAngle(angle):Resized(7.5), false, true, false, player, 1)
						boneTear:ChangeVariant(TearVariant.BONE)
					end
				end
			else
				player:GetData()['usedPhantom'] = false
				player:GetData()['usedHorsePhantom'] = false
			end
		end
		
		if player:HasCollectible(Collectibles.CATINBOX) and CustomData.Items.CATINBOX.RoomEnterFrame
		and game:GetFrameCount() == CustomData.Items.CATINBOX.RoomEnterFrame + 90 then
			for _, enemy in pairs(Isaac.FindInRadius(player.Position, 800, EntityPartition.ENEMY)) do
				if not enemy:IsBoss() then 
					enemy:AddHealth(enemy.MaxHitPoints)
				end
			end
		end
		
		if player:HasCollectible(Collectibles.MOTHERSLOVE) then
			if CustomData.Items.MOTHERSLOVE.NumFriends ~= #Isaac.FindByType(3, -1, -1, false, false) then
				CustomData.Items.MOTHERSLOVE.NumStats = 0
				if #Isaac.FindByType(3, -1, -1, false, false) > 0 then
					for _, friend in pairs(Isaac.FindByType(3, -1, -1, false, false)) do
						LoveStatMulGiven = getMothersLoveStatBoost(friend.Variant)
						
						CustomData.Items.MOTHERSLOVE.NumStats = CustomData.Items.MOTHERSLOVE.NumStats + LoveStatMulGiven
					end
				end
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_RANGE)
				player:EvaluateItems()
				
				CustomData.Items.MOTHERSLOVE.NumFriends = #Isaac.FindByType(3, -1, -1, false, false)
			end
		end
		
		if player:HasCollectible(Collectibles.SCALPEL) and game:GetFrameCount() % 6 == 0 then
			for i = 4, 7 do -- shooting left, right, up, down
				if Input.IsActionPressed(i, player.ControllerIndex) then
					local RedTear = player:FireTear(player.Position + DIRECTION_VECTOR[player:GetFireDirection()]:Resized(25), Vector.FromAngle(DIRECTION_VECTOR[player:GetFireDirection()]:GetAngleDegrees() + math.random(-10, 10)):Resized(-8), false, true, false, player, 0.66)
					RedTear.FallingAcceleration = 0.8
					RedTear.FallingSpeed = -8
					if RedTear.Variant ~= TearVariant.BLOOD then RedTear:ChangeVariant(TearVariant.BLOOD) end
				end
			end
		end
		
		if player:HasCollectible(Collectibles.NERVEPINCH) and CustomData.Items.NERVEPINCH.Hold <= 0 then
			CustomData.Items.NERVEPINCH.Hold = NERVEPINCH_HOLD
			player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 30)
			CustomData.Items.NERVEPINCH.NumTriggers = CustomData.Items.NERVEPINCH.NumTriggers + 1
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
			local primaryItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			
			if Isaac.GetItemConfig():GetCollectible(primaryItem).MaxCharges > 0
			and not (primaryItem == 490 or primaryItem == 585)
			and math.random(100) <= NERVEPINCH_USE_CHANCE then
				player:UseActiveItem(primaryItem, 0, -1)
			end
		end
		
		if game:GetFrameCount() % 450 == 0 then
			if player:GetData()['fightingSiblings'] == true then
				for _, f in pairs(Isaac.GetRoomEntities()) do
					if f.Type == 3 and
					(f.Variant == Familiars.SIBLING1 or f.Variant == Familiars.SIBLING2) then
						f:Remove()
					end
				end
				sfx:Play(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1, 2, false, 1, 0)
				if player:HasCollectible(Collectibles.SIBLINGRIVALRY) then 
					Isaac.Spawn(3, Familiars.FIGHTINGSIBLINGS, 0, player.Position, Vector.Zero, nil)
					player:GetData()['fightingSiblings'] = false
				end
			elseif player:GetData()['fightingSiblings'] == false then
				for _, f in pairs(Isaac.GetRoomEntities()) do
					if f.Type == 3 and f.Variant == Familiars.FIGHTINGSIBLINGS then
						f:Remove()
					end
				end
				if player:HasCollectible(Collectibles.SIBLINGRIVALRY) then 				
					Isaac.Spawn(3, Familiars.SIBLING1, 0, player.Position, Vector.Zero, nil)
					Isaac.Spawn(3, Familiars.SIBLING2, 0, player.Position, Vector.Zero, nil)
					player:GetData()['fightingSiblings'] = true
				end
			elseif player:GetData()['fightingSiblings'] == nil 
			and player:HasCollectible(Collectibles.SIBLINGRIVALRY) then
				player:GetData()['fightingSiblings'] = true
			end
		end
		
		if player:HasTrinket(Trinkets.TORNPAGE) and player:HasCollectible(CollectibleType.COLLECTIBLE_HOW_TO_JUMP)
		and sprite:IsPlaying("Jump") and sprite:GetFrame() == 18 then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat()
			local Angles = {45, 135, 225, 315}
			
			if roll <= 0.5 then
				Angles = {0, 90, 180, 270}
			end
			
			for _, angle in pairs(Angles) do
				player:FireTear(player.Position, Vector.FromAngle(angle):Resized(7.5), true, true, false, player, 0.75)
			end
		end
		
		if player:HasCollectible(Collectibles.REDKING) and room:GetType() == RoomType.ROOM_BOSS and stage < 9
		and math.abs(player.Position.X - 320) < 20 and math.abs(player.Position.Y - 280) < 20 
		and #Isaac.FindByType(6, 334, -1, false, false) > 0 
		and not CustomData.Items.REDKING.IsInRedKingRoom and not CustomData.Items.REDKING.DefeatedRedKingBoss then
			Isaac.ExecuteCommand("goto s.boss." .. tostring(REDKING_BOOSROOM_IDS[math.random(#REDKING_BOOSROOM_IDS)]))
			CustomData.Items.REDKING.DescendedRedCrawlspace = true
		end
		
		if player:GetData()['BagUsed'] then
			if game:GetFrameCount() < CustomData.Items.BOTTOMLESSBAG.UseFrame + 120 then
				for _, entity in pairs(Isaac.FindInRadius(player.Position, 40, EntityPartition.PROJECTILE)) do
					if entity:ToProjectile() then
						entity:Remove()     
						CustomData.Items.BOTTOMLESSBAG.TearCount = CustomData.Items.BOTTOMLESSBAG.TearCount + 1
					end
				end
				
				if game:GetFrameCount() < CustomData.Items.BOTTOMLESSBAG.UseFrame + 100 then
					for _, entity in pairs(Isaac.FindInRadius(player.Position, 300, EntityPartition.PROJECTILE)) do
						if entity:ToProjectile() then
							entity:AddVelocity((player.Position - entity.Position):Normalized())   
						end
					end
				elseif game:GetFrameCount() == CustomData.Items.BOTTOMLESSBAG.UseFrame + 100 then
					player:AnimateCollectible(Collectibles.BOTTOMLESSBAG, "HideItem", "PlayerPickupSparkle")
					local shootVector = DIRECTION_VECTOR[player:GetFireDirection()]
					
					for i = 1, CustomData.Items.BOTTOMLESSBAG.TearCount do
						extraOffset = Vector(math.random(-5,5), math.random(-5,5))
						local vacuumTear = player:FireTear(player.Position, shootVector * math.random(6, 15) + extraOffset, false, true, false, player)
						vacuumTear.TearFlags = vacuumTear.TearFlags | TearFlags.TEAR_HOMING 
						local color = Color(1, 1, 1, 1, 0, 0, 0)
						color:SetColorize(1, 0, 1, 1)
						vacuumTear:SetColor(color, 0, 0, true, false)
					end
				end
			else
				CustomData.Items.BOTTOMLESSBAG.TearCount = 0
				CustomData.Items.BOTTOMLESSBAG.UseFrame = 0
				player:GetData()['BagUsed'] = false
			end
		end
	end
	
	-- black chests
	for _, bc in pairs(Isaac.FindByType(5, PickUps.BLACKCHEST, 2, false, false)) do
		if bc:GetData()['OpenFrame'] and game:GetFrameCount() >= bc:GetData()['OpenFrame'] + 60 then
			local bcSprite = bc:GetSprite()
			
			bcSprite:Play("Close")
			sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			bc.SubType = 0
		end
	end
	
	-- stargazer
	for _, sg in pairs(Isaac.FindByType(6, PickUps.SLOT_STARGAZER, -1, false, false)) do
		local SGSprite = sg:GetSprite()
		
		if SGSprite:IsFinished("PayPrize") then
			if math.random(100) <= STARGAZER_PAYOUT_CHANCE then
				SGSprite:Play("Teleport")
			else
				SGSprite:Play("Prize")
			end
		elseif SGSprite:IsFinished("Teleport") then
			sg:Remove()
		elseif SGSprite:IsFinished("Prize") then
			SGSprite:Play("Idle")
		end
		
		if SGSprite:IsPlaying("Teleport") and SGSprite:IsEventTriggered("Disappear") then
			Isaac.Spawn(5, 100, ItemPools.STARGAZER[math.random(#ItemPools.STARGAZER)], Vector(sg.Position.X, sg.Position.Y + 40), Vector.Zero, nil)
			sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 2, false, 1, 0)
		end
		
		if SGSprite:IsPlaying("Prize") and SGSprite:IsEventTriggered("Prize") then
			RNGobj:SetSeed(Random() + 1, 1)
			local Rune = RNGobj:RandomInt(9) + 32
			Isaac.Spawn(5, 300, Rune, sg.Position, Vector.FromAngle(math.random(360)) * 5, nil)
			sfx:Play(SoundEffect.SOUND_SLOTSPAWN, 1, 2, false, 1, 0)
		end
	end
	
	-- bloody rocks
	for ind = 1, room:GetGridSize() do
		local gridEnt = room:GetGridEntity(ind)
		
		if gridEnt and gridEnt:GetType() == GridEntityType.GRID_ROCK_SPIKED and gridEnt:GetVariant() == 2
		and gridEnt.State == 2 and gridEnt.VarData == 0 then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			if roll < 20 then
				Isaac.Spawn(5, 300, Card.CARD_CRACKED_KEY, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
				Isaac.Spawn(5, 300, PocketItems.REDRUNE, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
			elseif roll < 45 then
				Isaac.Spawn(5, 300, PocketItems.REDRUNE, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
				Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
			elseif roll < 65 then
				Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
				Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
			elseif roll < 70 then
				Isaac.Spawn(5, PickUps.SCARLETCHEST, 0, gridEnt.Position, Vector.Zero, nil)
			else
				Isaac.Spawn(5, 300, Card.CARD_CRACKED_KEY, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
				Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, nil)
			end
			
			gridEnt.VarData = 1
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_UPDATE, rplus.OnFrame)

						-- MC_USE_ITEM --										
						-----------------
function rplus:OnItemUse(ItemUsed, _, Player, _, Slot, _)
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	if ItemUsed == Collectibles.COOKIECUTTER then
		Player:AddMaxHearts(2, true)
		Player:AddBrokenHearts(1)
		sfx:Play(SoundEffect.SOUND_BLOODBANK_SPAWN, 1, 2, false, 1, 0)
		if Player:GetBrokenHearts() >= 12 then
			Player:Die()
		end
		return true
	end
	
	if ItemUsed == Collectibles.CHEESEGRATER and Player:GetMaxHearts() > 0 then
		Player:AddMaxHearts(-2, false)
		Player:AddMinisaac(Player.Position, true)
		Player:AddMinisaac(Player.Position, true)
		Player:AddMinisaac(Player.Position, true)
		sfx:Play(SoundEffect.SOUND_BLOODBANK_SPAWN, 1, 2, false, 1, 0)
		Player:GetData()['graterUsed'] = true
		
		CustomData.Items.CHEESEGRATER.NumUses = CustomData.Items.CHEESEGRATER.NumUses + 1
		Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		Player:EvaluateItems()
	end
	
	if ItemUsed == Collectibles.RUBIKSCUBE then
		RNGobj:SetSeed(Random() + 1, 1)
		local solveChance = RNGobj:RandomInt(100) + 1
		
		if solveChance <= 5 or CustomData.Items.RUBIKSCUBE.Counter == 20 then
			Player:RemoveCollectible(Collectibles.RUBIKSCUBE, true, ActiveSlot.SLOT_PRIMARY, true)
			Player:AddCollectible(Collectibles.MAGICCUBE, 4, true, ActiveSlot.SLOT_PRIMARY, 0)
			Player:AnimateHappy()
			CustomData.Items.RUBIKSCUBE.Counter = 0
			return false
		else
			CustomData.Items.RUBIKSCUBE.Counter = CustomData.Items.RUBIKSCUBE.Counter + 1
			return true
		end
	end
	
	if ItemUsed == Collectibles.MAGICCUBE then
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 5 and entity.Variant == 100 and entity.SubType > 0 then
				entity:ToPickup():Morph(5, 100, GetUnlockedVanillaCollectible(true), true, false, true)
			end
		end
		return true
	end
	
	if ItemUsed == Collectibles.QUASAR then
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 5 and entity.Variant == 100 and entity.SubType > 0 
			and entity:ToPickup() and entity:ToPickup().Price % 10 == 0 then
				for i = 1, 3 do
					repeat 
						newID = GetUnlockedVanillaCollectible()
					until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
					Player:AddItemWisp(newID, Player.Position, true)
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
					entity:Remove()
				end
				sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 2, false, 1, 0)
			end
		end

		return true
	end
	
	if ItemUsed == Collectibles.TOWEROFBABEL then
		for g = 1, room:GetGridSize() do
			if room:GetGridEntity(g) then room:GetGridEntity(g):Destroy() end
		end
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 200, EntityPartition.ENEMY)) do
			if not enemy:IsBoss() then enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION) end
		end
		return {Discharge = true, Remove = false, ShowAnim = true}
	end
	
	if ItemUsed == Collectibles.BOOKOFGENESIS then 
		local freezePreventChecker = 0
		CustomData.Items.BOOKOFGENESIS.Index = CustomData.Items.BOOKOFGENESIS.Index + 1
		
		repeat
			ID = Player:GetDropRNG():RandomInt(Isaac.GetItemConfig():GetCollectibles().Size - 1) + 1
			freezePreventChecker = freezePreventChecker + 1
		until (Player:HasCollectible(ID, true)
		and Isaac.GetItemConfig():GetCollectible(ID).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
		and Isaac.GetItemConfig():GetCollectible(ID).Type % 3 == 1)
		or freezePreventChecker == 10000
		
		if freezePreventChecker < 10000 then
			Player:RemoveCollectible(ID, true, -1, true)
		
			local Q = Isaac.GetItemConfig():GetCollectible(ID).Quality
			for i = 1, (Player:HasTrinket(Trinkets.TORNPAGE) and 4 or 3) do
				repeat 
					newID = GetUnlockedVanillaCollectible(true)
				until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1 and Isaac.GetItemConfig():GetCollectible(newID).Quality == Q
				and Isaac.GetItemConfig():GetCollectible(newID).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
				
				local bookOfGenesisItem = Isaac.Spawn(5, 100, newID, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil):ToPickup()
				bookOfGenesisItem.OptionsPickupIndex = CustomData.Items.BOOKOFGENESIS.Index
			end
			sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 2, false, 1, 0)
			return {Discharge = true, Remove = false, ShowAnim = true}
		else 
			return {Discharge = false, Remove = false, ShowAnim = false}
		end
	end
	
	for i = 1, #Collectibles.BLOODVESSELS do
		if ItemUsed == Collectibles.BLOODVESSELS[i] then
			if i == 7 and Player:GetDamageCooldown() <= 0 then
				CustomData.Items.BLOODVESSEL.DamageFlag = true
				Player:TakeDamage(6, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(Player), 18)
				Player:RemoveCollectible(Collectibles.BLOODVESSELS[7])
				Player:AddCollectible(Collectibles.BLOODVESSELS[1])
				CustomData.Items.BLOODVESSEL.DamageFlag = false
			else
				return false
			end
		end
	end
	
	if Player:HasTrinket(Trinkets.TORNPAGE) then
		-- bible removes one broken heart
		if ItemUsed == CollectibleType.COLLECTIBLE_BIBLE then
			Player:AddBrokenHearts(-2)
		-- book of the dead gives you a bone heart
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD then
			Player:AddBoneHearts(1)
		-- book of belial also grants eye of belial effect for the room
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL then
			Player:GetData()['enhancedBoB'] = true
			Player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
			Player:EvaluateItems()		
		-- telepathy for dummies also grants range up for the room
		elseif ItemUsed == CollectibleType.COLLECTIBLE_TELEPATHY_BOOK then
			Player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_THE_WIZ, true, 1)
		-- monster manual spawns weaker familiars when used (dips, flies and spiders)
		elseif ItemUsed == CollectibleType.COLLECTIBLE_MONSTER_MANUAL then
			for n = 1, 6 do
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomInt(100)
				
				if roll <= 33 then
					Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, 0, Player.Position, Vector.Zero, nil)
				elseif roll <= 67 then
					Isaac.Spawn(3, FamiliarVariant.BLUE_SPIDER, 0, Player.Position, Vector.Zero, nil)
				else
					Isaac.Spawn(3, FamiliarVariant.DIP, 0, Player.Position, Vector.Zero, nil)
				end
			end
		-- other books get a complimentary charge decrease
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS or
		ItemUsed == CollectibleType.COLLECTIBLE_LEMEGETON or
		ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES or
		ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS or
		ItemUsed == CollectibleType.COLLECTIBLE_NECRONOMICON then
			Player:SetActiveCharge(Player:GetActiveCharge(Slot) + 1, Slot)
		end
	end
	
	if Player:HasTrinket(Trinkets.EMPTYPAGE) then
		if ItemUsed == CollectibleType.COLLECTIBLE_BIBLE
		or ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD
		or ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL
		or ItemUsed == CollectibleType.COLLECTIBLE_NECRONOMICON
		or ItemUsed == CollectibleType.COLLECTIBLE_TELEPATHY_BOOK
		or ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS
		or ItemUsed == CollectibleType.COLLECTIBLE_SATANIC_BIBLE
		or ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SIN
		or ItemUsed == CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK
		or ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS
		or ItemUsed == CollectibleType.COLLECTIBLE_MONSTER_MANUAL
		or ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES
		or ItemUsed == CollectibleType.COLLECTIBLE_LEMEGETON
		or ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS
		or ItemUsed == Collectibles.BOOKOFGENESIS
		then
			Player:UseActiveItem(ItemPools.EMPTYPAGEACTIVES[math.random(#ItemPools.EMPTYPAGEACTIVES)], UseFlag.USE_NOANIM, -1)
		end
	end
	
	if ItemUsed == Collectibles.STARGAZERSHAT then
		Player:AnimateCollectible(ItemUsed, "Pickup", "PlayerPickupSparkle")
		sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 2, false, 1, 0)
		Isaac.Spawn(6, PickUps.SLOT_STARGAZER, 0, Isaac.GetFreeNearPosition(Player.Position, 40), Vector.Zero, nil)
	end
	
	if ItemUsed == Collectibles.BOTTOMLESSBAG then 
		Player:GetData()['BagUsed'] = true
		CustomData.Items.BOTTOMLESSBAG.UseFrame = game:GetFrameCount()
		CustomData.Items.BOTTOMLESSBAG.Data = true
		Player:AnimateCollectible(Collectibles.BOTTOMLESSBAG, "LiftItem", "PlayerPickupSparkle")
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_ITEM, rplus.OnItemUse)

						-- MC_USE_CARD -- 										
						-----------------
function rplus:CardUsed(CardUsed, Player, _)	
	if CardUsed == PocketItems.RJOKER then
		game:StartRoomTransition(-6, -1, RoomTransitionAnim.TELEPORT, Player, -1)
	end
	
	if CardUsed == PocketItems.SDDSHARD then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_SPINDOWN_DICE, UseFlag.USE_NOANIM, -1)
	end
	
	if CardUsed == PocketItems.BUSINESSCARD then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_FRIEND_FINDER, UseFlag.USE_NOANIM, -1)
	end
	
	if CardUsed == PocketItems.REDRUNE then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_ABYSS, false, false, true, false, -1)
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false, false, true, false, -1)
		RNGobj:SetSeed(Random() + 1, 1)
		
		for _, entity in pairs(Isaac.FindInRadius(Player.Position, 1000, EntityPartition.PICKUP)) do
			if ((entity.Variant < 100 and entity.Variant > 0) or entity.Variant == 300 or entity.Variant == 350 or entity.Variant == 360) 
			and entity:ToPickup() and entity:ToPickup().Price % 10 == 0 then
				local pos = entity.Position
				
				entity:Remove()
				if math.random(100) <= 50 then
					Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, RNGobj:RandomInt(5) + 1, pos, Vector.Zero, nil)
				end
			end
		end
	end
	
	if CardUsed == PocketItems.REVERSECARD then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false, false, true, false, -1)
		Player:GetData()["reverseCardRoom"] = game:GetLevel():GetCurrentRoomIndex()
	end
	
	if CardUsed == PocketItems.KINGOFSPADES then
		sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 2, false, 1, 0)
		local NumPickups = math.floor(Player:GetNumKeys() / 4)
		Player:AddKeys(-Player:GetNumKeys())
		if Player:HasGoldenKey() then Player:RemoveGoldenKey() NumPickups = NumPickups + 2 end
		for i = 1, NumPickups do
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, false, false, true, false, -1)
		end
		if NumPickups >= 3 then Isaac.Spawn(5, 350, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
		if NumPickups >= 7 then Isaac.Spawn(5, 100, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
	end
	
	if CardUsed == PocketItems.KINGOFCLUBS then
		local NumPickups = math.floor(Player:GetNumBombs() / 4)
		Player:AddBombs(-Player:GetNumBombs())
		if Player:HasGoldenBomb() then Player:RemoveGoldenBomb() NumPickups = NumPickups + 2 end
		for i = 1, NumPickups do
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, false, false, true, false, -1)
		end
		if NumPickups >= 3 then Isaac.Spawn(5, 350, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
		if NumPickups >= 7 then Isaac.Spawn(5, 100, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
	end
	
	if CardUsed == PocketItems.KINGOFDIAMONDS then
		local NumPickups = math.floor(Player:GetNumCoins() / 5)
		Player:AddCoins(-Player:GetNumCoins())
		for i = 1, NumPickups do
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, false, false, true, false, -1)
		end
		if NumPickups >= 3 then Isaac.Spawn(5, 350, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
		if NumPickups >= 7 then Isaac.Spawn(5, 100, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
	end
	
	if CardUsed == PocketItems.NEEDLEANDTHREAD then
		if Player:GetBrokenHearts() > 0 then
			Player:AddBrokenHearts(-1)
			Player:AddMaxHearts(2, true)
			Player:AddHearts(2)
		end
	end
	
	if CardUsed == PocketItems.QUEENOFDIAMONDS then
		for i = 1, math.random(12) do
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat()
			local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false)
			
			if roll < 0.92 then
				Isaac.Spawn(5, PickupVariant.PICKUP_COIN, 1, spawnPos, Vector.Zero, nil)
			elseif roll < 0.98 then
				Isaac.Spawn(5, PickupVariant.PICKUP_COIN, 2, spawnPos, Vector.Zero, nil)
			else
				Isaac.Spawn(5, PickupVariant.PICKUP_COIN, 3, spawnPos, Vector.Zero, nil)
			end
		end
	end
	
	if CardUsed == PocketItems.QUEENOFCLUBS then
		for i = 1, math.random(12) do
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat()
			local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false)
			
			if roll < 0.92 then
				Isaac.Spawn(5, PickupVariant.PICKUP_BOMB, 1, spawnPos, Vector.Zero, nil)
			else
				Isaac.Spawn(5, PickupVariant.PICKUP_BOMB, 2, spawnPos, Vector.Zero, nil)
			end
		end
	end
	
	if CardUsed == PocketItems.BAGTISSUE then
		local Weights = {}
		local SumWeight = 0
		local EnoughConsumables = true
		
		-- getting total weight of 8 most valuable pickups in a room
		for _, entity in pairs(Isaac.FindInRadius(Player.Position, 1000, EntityPartition.PICKUP)) do
			if entity:ToPickup() and entity:ToPickup().Price % 10 == 0 then
				if PickupWeights[entity.Variant] and PickupWeights[entity.Variant][entity.SubType] then
					table.insert(Weights, PickupWeights[entity.Variant][entity.SubType])
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
					entity:Remove()
				elseif entity.Variant == 70 then
					table.insert(Weights, 2)
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
					entity:Remove()
				elseif entity.Variant == 300 then
					table.insert(Weights, 3)
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
					entity:Remove()
				end
			end
		end
		
		table.sort(Weights, function(a,b) return a>b end)
		for i = 1, 8 do
			if not Weights[i] then
				EnoughConsumables = false 
				Player:AnimateSad() 
				break
			end
			SumWeight = SumWeight + Weights[i]
		end


		if EnoughConsumables then
			-- defining item quality 
			DesiredQuality = math.min(math.floor(SumWeight / 9), 4)
			
			-- trying to get random (not story-related!!) item with desired quality
			repeat
				ID = GetUnlockedVanillaCollectible(true)
			until Isaac.GetItemConfig():GetCollectible(ID).Quality == DesiredQuality
			and Isaac.GetItemConfig():GetCollectible(ID).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
			
			-- spawning the item
			Player:AnimateHappy()
			Isaac.Spawn(5, 100, ID, Isaac.GetFreeNearPosition(Player.Position, 5.0), Vector.Zero, nil)
		end
	end
	
	if CardUsed == PocketItems.LOADEDDICE then
		Player:GetData()['usedLoadedDice'] = true
		
		Player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		Player:EvaluateItems()
	end
	
	-- jacks
	if CardUsed == PocketItems.JACKOFDIAMONDS then
		CustomData.Cards.JACK = "Diamonds"
	elseif CardUsed == PocketItems.JACKOFCLUBS then
		CustomData.Cards.JACK = "Clubs"
	elseif CardUsed == PocketItems.JACKOFSPADES then
		CustomData.Cards.JACK = "Spades"	
	elseif CardUsed == PocketItems.JACKOFHEARTS then
		CustomData.Cards.JACK = "Hearts"
	end
	
	if CardUsed == PocketItems.BEDSIDEQUEEN then		
		for i = 1, math.random(12) do
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat()
			
			if roll < 0.95 then
				Isaac.Spawn(5, PickupVariant.PICKUP_KEY, 1, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil)
			else
				Isaac.Spawn(5, PickupVariant.PICKUP_KEY, 4, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil)
			end
		end
	end
	
	if CardUsed == PocketItems.QUASARSHARD then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM, -1)
		
		for _, entity in pairs(Isaac.FindInRadius(Player.Position, 1000, EntityPartition.PICKUP)) do
			if entity.Variant == 100 and entity.SubType > 0
			and entity:ToPickup() and entity:ToPickup().Price % 10 == 0 then
				for i = 1, 3 do
					repeat 
						newID = GetUnlockedVanillaCollectible()
					until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
					Player:AddItemWisp(newID, Player.Position, true)
				end
				Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
				entity:Remove()
				sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 2, false, 1, 0)
			end
		end
	end
	
	if CardUsed == PocketItems.SACBLOOD and CustomData then
		CustomData.Cards.SACBLOOD.Data = true
		CustomData.Cards.SACBLOOD.NumUses = CustomData.Cards.SACBLOOD.NumUses + 1
		Step = 0
		Player:GetData()['usedBlood'] = true
		
		sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 2, false, 1, 0)
		if Player:HasCollectible(216) then Player:AddHearts(2) end		-- bonus for ceremonial robes ;)
	end
	
	if CardUsed == PocketItems.FLYPAPER then
		for i = 1, 9 do
			Player:AddSwarmFlyOrbital(Player.Position)
		end
	end
	
	if CardUsed == PocketItems.LIBRARYCARD then
		Player:UseActiveItem(game:GetItemPool():GetCollectible(ItemPoolType.POOL_LIBRARY, false, Random() + 1, 0), true, false, true, true, -1)
	end
	
	if CardUsed == PocketItems.FUNERALSERVICES then
		Isaac.Spawn(5, PickupVariant.PICKUP_OLDCHEST, 0, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil)
	end
	
	if CardUsed == PocketItems.MOMSID then
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 560, EntityPartition.ENEMY)) do
			if not enemy:IsBoss() then enemy:AddEntityFlags(EntityFlag.FLAG_CHARM) end
		end
	end
	
	if CardUsed == PocketItems.ANTIMATERIALCARD then
		local antimaterialCardTear = Isaac.Spawn(2, TearVariants.ANTIMATERIALCARD, 0, Player.Position, DIRECTION_VECTOR[Player:GetMovementDirection()]:Resized(10), nil)
		antimaterialCardTear:GetSprite():Play("Rotate")
	end
	
	if CardUsed == PocketItems.DEMONFORM and CustomData then
		Player:GetData()['usedDemonForm'] = true
	end
	
	if CardUsed == PocketItems.FIENDFIRE then 
		local Counter = 0
		
		for i = 1, 300 do
			RNGobj:SetSeed(Random() + 1, 1)
			local RandomPickup = RNGobj:RandomInt(3) + 1
			
			if RandomPickup == 1 and Player:GetNumCoins() > 0 then
				Player:AddCoins(-1)
				Counter = Counter + 1
			elseif RandomPickup == 2 and Player:GetNumKeys() > 0 then
				Player:AddKeys(-1)
				Counter = Counter + 1
			elseif RandomPickup == 3 and Player:GetNumBombs() > 0 then
				Player:AddBombs(-1)
				Counter = Counter + 1
			end
			
			if Counter == 120 or Player:GetNumKeys() + Player:GetNumBombs() + Player:GetNumCoins() == 0 then 
				break 
			end 
		end
		
		if Counter >= 7 and Counter <= 40 then 
		-- enemies take damage and are set on fire
			for _, enemy in pairs(Isaac.GetRoomEntities()) do
				if enemy:IsVulnerableEnemy() then 
					enemy:TakeDamage(15, 1, EntityRef(Player), 0)
					enemy:AddBurn(EntityRef(Player), 120, Player.Damage)
				end
			end
		elseif Counter > 40 and Counter <= 80 then 
		-- more damage, longer burn duration, destroy grid entities around you
			for _, enemy in pairs(Isaac.GetRoomEntities()) do
				if enemy:IsVulnerableEnemy() then 
					enemy:TakeDamage(30, 1, EntityRef(Player), 0)
					enemy:AddBurn(EntityRef(Player), 240, 2 * Player.Damage)
				end
			end
			for g = 1, room:GetGridSize() do
				if room:GetGridEntity(g) 
				and room:GetGridPosition(g):Distance(Player.Position) < 150 then 
					room:GetGridEntity(g):Destroy() 
				end
			end
		elseif Counter > 80 and Counter <= 120 then 
		-- produce mama mega explosion, longer burn duration
			Isaac.Spawn(1000, 127, 0, Player.Position, Vector.Zero, nil) -- mama mega explosion
			for _, enemy in pairs(Isaac.GetRoomEntities()) do
				if enemy:IsVulnerableEnemy() then 
					enemy:AddBurn(EntityRef(Player), 480, 4 * Player.Damage)
				end
			end 
		end
		
		sfx:Play(SoundEffect.SOUND_WAR_HORSE_DEATH, 1, 2, false, 1, 0)
		Game():ShakeScreen(30)
	end
	
	if CardUsed == Card.CARD_SOUL_CAIN then
		for _, chest in pairs(Isaac.FindByType(5, PickUps.SCARLETCHEST, -1, false, false)) do
			if chest.SubType == 0 or chest.SubType == 2 then
				openScarletChest(chest)
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_CARD, rplus.CardUsed)

						-- MC_USE_PILL --	
						-----------------
function rplus:usePill(pillEffect, Player, _)
	-- a way to distinguish the "horse-ness" of the pill:
	-- if the player holds a horse pill in the main slot at the moment of using the pill,
	-- it is most likely a horse pill (thanks API)
	local pillColor = game:GetItemPool():ForceAddPillEffect(pillEffect)
	if Player:GetPill(0) >= 2048 then 
		pillColor = pillColor + 2048 
	end
		
	if pillEffect == Pills.ESTROGEN then	-- no horse bonus effects
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
		local BloodClots = Player:GetHearts() - 2 
		
		Player:AddHearts(-BloodClots)
		for i = 1, BloodClots do
			Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, 0, Player.Position, Vector.Zero, nil)
		end
	end
	
	if pillEffect == Pills.LAXATIVE then
		if pillColor < 2048 then
			Player:GetData()['usedLax'] = true
		else
			Player:GetData()['usedHorseLax'] = true	-- increased duration for horse pill
		end
		CustomData.Pills.LAXATIVE.UseFrame = game:GetFrameCount()
		sfx:Play(SoundEffect.SOUND_FART, 1, 2, false, 1, 0)
		Player:AnimateSad()
	end
	
	if Player:HasCollectible(Collectibles.DNAREDACTOR) then
		-- I honestly don't want to look at this ever again
		if pillColor % 2048 == PillColor.PILL_BLUE_BLUE then
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_CLICKER, true, true, false, false, -1)			-- change character
		elseif pillColor == PillColor.PILL_WHITE_BLUE then
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, true, true, false, false, -1)		-- wavy cap use
		elseif pillColor == PillColor.PILL_WHITE_BLUE + 2048 then
			for n = 1, 4 do
				Player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, true, true, false, false, -1)	-- 4 wavy cap uses
			end
		elseif pillColor % 2048 == PillColor.PILL_ORANGE_ORANGE then
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_D100, true, true, false, false, -1)			-- D100 use
		elseif pillColor % 2048 == PillColor.PILL_WHITE_WHITE then
			Player:AddPill(pillColor)																		-- the pill replicates itself constantly
		elseif pillColor % 2048 == PillColor.PILL_REDDOTS_RED then
			Isaac.Explode(Player.Position, Player, 110)														-- explosion
			if pillColor == PillColor.PILL_REDDOTS_RED then
				Player:TakeDamage(1, 0, EntityRef(Player), 30)
			end
		elseif pillColor % 2048 == PillColor.PILL_PINK_RED then
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK, true, true, false, false, -1)			-- Berserk mode
			if pillColor == PillColor.PILL_PINK_RED + 2048 then
				CustomData.Items.TEMPERTANTRUM.SuperBerserkState = true
				player:GetData()['pillInvokedSuperBerserkState'] = true
			end
		elseif pillColor % 2048 == PillColor.PILL_BLUE_CADETBLUE then
			game:StartRoomTransition(-2, -1, RoomTransitionAnim.TELEPORT, Player, -1)						-- teleport to the Error room
		elseif pillColor == PillColor.PILL_YELLOW_ORANGE then
			Player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)												-- discharge your active item
		elseif pillColor == PillColor.PILL_YELLOW_ORANGE + 2048 then
			Player:SetActiveCharge(12, ActiveSlot.SLOT_PRIMARY)
		elseif pillColor % 2048 == PillColor.PILL_ORANGEDOTS_WHITE then
			SilentUseCard(Player, Card.CARD_GET_OUT_OF_JAIL)												-- open all doors
			if pillColor == PillColor.PILL_ORANGEDOTS_WHITE + 2048 then
				SilentUseCard(Player, Card.CARD_SOUL_CAIN)													-- and the red doors too
			end
		elseif pillColor % 2048 == PillColor.PILL_WHITE_AZURE then
			local myPocketItem = Player:GetActiveItem(ActiveSlot.SLOT_POCKET)
			Player:SetPill(0, 0)
			SilentUseCard(Player, Card.CARD_REVERSE_FOOL)													-- reverse Fool (drop all your stuff)
			if myPocketItem ~= 0 then 
				Player:AddCollectible(myPocketItem, 12, false, ActiveSlot.SLOT_POCKET, 0)
			end
			if pillColor == PillColor.PILL_WHITE_AZURE + 2048 then
				SilentUseCard(Player, Card.CARD_JUSTICE)													-- add some more stuff
			end
		elseif pillColor % 2048 == PillColor.PILL_BLACK_YELLOW then
			if pillColor == PillColor.PILL_BLACK_YELLOW + 2048 then
				for i = 1, 3 do
					Isaac.GridSpawn(GridEntityType.GRID_POOP, 3, game:GetRoom():FindFreeTilePosition(Player.Position, 500), true)
				end
			end
			SilentUseCard(Player, Card.CARD_HUMANITY)														-- Card against humanity (shit on the floor)
		elseif pillColor == PillColor.PILL_WHITE_BLACK then
			Isaac.Spawn(5, 350, 0, Player.Position, Vector.Zero, nil)										-- spawn a random trinket
		elseif pillColor == PillColor.PILL_WHITE_BLACK + 2048 then
			Isaac.Spawn(5, 350, TrinketType.TRINKET_GOLDEN_FLAG + math.random(1, 189), Player.Position, Vector.Zero, nil)	
		elseif pillColor == PillColor.PILL_WHITE_YELLOW then
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, true, true, false, false, -1)	-- restart the floor
		elseif pillColor == PillColor.PILL_WHITE_YELLOW + 2048 then
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_R_KEY, true, true, false, false, -1)			-- restart the run (R key)
			Player:RemoveCollectible(Collectibles.DNAREDACTOR)
		end
	end
	
	if pillEffect == Pills.PHANTOM and CustomData
	and not isInGhostForm(Player) then
		if pillColor < 2048 then
			Player:GetData()['usedPhantom'] = true
		else
			Player:GetData()['usedHorsePhantom'] = true	-- taking fake damage will also cause to shoot 8 bone tears in all directions
		end
		CustomData.Pills.PHANTOM.UseFrame = game:GetFrameCount()
	end
	
	if pillEffect == Pills.YUCK and CustomData then
		if pillColor < 2048 then
			Player:GetData()['usedYuck'] = true
		else
			Player:GetData()['usedHorseYuck'] = true	-- increased duration for horse pill
		end
		CustomData.Pills.YUCK.UseFrame = game:GetFrameCount()
		Isaac.Spawn(5, 10, 12, Player.Position, Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
	end
	
	if pillEffect == Pills.YUM and CustomData then
		if pillColor < 2048 then
			Player:GetData()['usedYum'] = true
		else
			Player:GetData()['usedHorseYum'] = true	-- increased duration for horse pill
		end
		CustomData.Pills.YUM.UseFrame = game:GetFrameCount()
		Isaac.Spawn(5, 10, 1, Player.Position, Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_PILL, rplus.usePill)

						-- MC_POST_PLAYER_UPDATE --									
						---------------------------
function rplus:PostPlayerUpdate(Player)
	local level = game:GetLevel()
	
	if Input.IsButtonTriggered(Keyboard.KEY_H, Player.ControllerIndex) and not hideErrorMessage then
		print('Error message hidden. To see it again, type *show* into the console')
		hideErrorMessage = true
	end	
	
	-- this callback handles inputs, because it rolls in 60 fps, unlike MC_POST_UPDATE, so inputs won't be missed out
	if Player:HasCollectible(Collectibles.ENRAGEDSOUL) then
		for i = 4, 7 do -- shooting left, right, up, down; reading first input
			if Input.IsActionTriggered(i, Player.ControllerIndex) and not ButtonState_soul then
				ButtonPressed_soul = i
				ButtonState_soul = "listening for second tap"
				PressFrame_soul = game:GetFrameCount()
				--print('button ' .. ButtonPressed_soul .. ' is pressed on frame ' .. PressFrame_soul)
			end
		end
		
		if PressFrame_soul and game:GetFrameCount() <= PressFrame_soul + 6 then -- listening for next inputs in the next 4 frames
			if not Input.IsActionTriggered(ButtonPressed_soul, Player.ControllerIndex) and ButtonState_soul == "listening for second tap" then
				ButtonState_soul = "button released"
			end
			
			if ButtonState_soul == "button released" and Input.IsActionTriggered(ButtonPressed_soul, Player.ControllerIndex) and 
			(not CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown or CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown <= 0) then
				--print('button ' .. ButtonPressed_soul .. ' double tapped')
				-- spawning the soul
				if (ButtonPressed_soul == 4 and not room:IsMirrorWorld()) or (ButtonPressed_soul == 5 and room:IsMirrorWorld()) then
					Velocity = DIRECTION_VECTOR[Direction.LEFT]
					DashAnim = "DashHoriz"
				elseif (ButtonPressed_soul == 5 and not room:IsMirrorWorld()) or (ButtonPressed_soul == 4 and room:IsMirrorWorld()) then
					Velocity = DIRECTION_VECTOR[Direction.RIGHT]
					DashAnim = "DashHoriz"
				elseif ButtonPressed_soul == 6 then
					Velocity = DIRECTION_VECTOR[Direction.UP]
					DashAnim = "DashUp"
				else
					Velocity = DIRECTION_VECTOR[Direction.DOWN]
					DashAnim = "DashDown"
				end
				CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown = ENRAGED_SOUL_COOLDOWN
				local Soul = Isaac.Spawn(3, Familiars.SOUL, 0, Player.Position, Velocity * 12, nil)
				Soul.CollisionDamage = 3.5 * (1 + math.sqrt(level:GetStage()))	-- new formula for calculacting the soul's damage
				
				local SoulSprite = Soul:GetSprite()
				
				SoulSprite:Load("gfx/003.214_enragedsoul.anm2", true)
				if (ButtonPressed_soul == 4 and not room:IsMirrorWorld()) or (ButtonPressed_soul == 5 and room:IsMirrorWorld()) then SoulSprite.FlipX = true end
				SoulSprite:Play(DashAnim, true)
				sfx:Play(SoundEffect.SOUND_ANIMA_BREAK, 1, 2, false, 1, 0)
				sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A, 1, 2, false, 1, 0)
				
				ButtonState_soul = nil
			end
		else
			ButtonState_soul = nil
		end
		
		if CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown then 
			CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown = CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown - 1
		end
	end
	
	if Player:GetSprite():IsPlaying("Appear") and Player:GetSprite():IsEventTriggered("FX") and level:GetCurses() ~= 0 
	and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= LevelCurse.CURSE_OF_LABYRINTH then
		if Player:HasTrinket(Trinkets.NIGHTSOIL) and math.random(100) < NIGHT_SOIL_CHANCE then
			level:RemoveCurses(level:GetCurses())
			game:GetHUD():ShowFortuneText("Night Soil protects you")
			Player:AnimateHappy()
		end
		
		if Player:HasCollectible(Collectibles.BLESSOTDEAD) then 
			CustomData.Items.BLESSOTDEAD.NumUses = CustomData.Items.BLESSOTDEAD.NumUses + 1
			game:GetHUD():ShowFortuneText("The Dead protect you")
			level:RemoveCurses(level:GetCurses())
			Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			Player:EvaluateItems()
		end
	end
	
	if Player:HasTrinket(Trinkets.MAGICSWORD) or Player:HasTrinket(Trinkets.BONEMEAL) then
		Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) 
		Player:EvaluateItems() 
	end
	
	if Player:HasCollectible(Collectibles.ORDLIFE) then 
		Player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY) 
		Player:EvaluateItems() 
	end
	
	if Player:HasCollectible(Collectibles.REDBOMBER) then
		if Input.IsActionTriggered(ButtonAction.ACTION_BOMB, Player.ControllerIndex) 
		and CustomData.Items.REDBOMBER.BombLaunchCooldown <= 0 then
			if Player:GetNumBombs() > 0 then
				CustomData.Items.REDBOMBER.BombLaunchCooldown = REDBOMBER_LAUNCH_COOLDOWN
			end
		end
		
		if CustomData.Items.REDBOMBER.BombLaunchCooldown then
			CustomData.Items.REDBOMBER.BombLaunchCooldown = CustomData.Items.REDBOMBER.BombLaunchCooldown - 1
		end
	end
	
	if Player:HasCollectible(Collectibles.MAGICPEN) then
		for i = 4, 7 do -- shooting left, right, up, down; reading first input
			if Input.IsActionTriggered(i, Player.ControllerIndex) and not ButtonState_pen then
				ButtonPressed_pen = i
				ButtonState_pen = "listening for second tap"
				PressFrame_pen = game:GetFrameCount()
			end
		end
		
		if PressFrame_pen and game:GetFrameCount() <= PressFrame_pen + 8 then
			if not Input.IsActionTriggered(ButtonPressed_pen, Player.ControllerIndex) and ButtonState_pen == "listening for second tap" then
				ButtonState_pen = "button released"
			end
			
			if ButtonState_pen == "button released" and Input.IsActionTriggered(ButtonPressed_pen, Player.ControllerIndex) and 
			(not CustomData.Items.MAGICPEN.CreepSpewCooldown or CustomData.Items.MAGICPEN.CreepSpewCooldown <= 0) then
				-- spewing the creep
				local creepDirection = DIRECTION_VECTOR[Player:GetFireDirection()]:Resized(20)
				for i = 1, 10 do
					Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 4, Player.Position + creepDirection * i, Vector.Zero, nil)
				end
				
				sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 2, false, 1, 0)
				CustomData.Items.MAGICPEN.CreepSpewCooldown = MAGICPEN_CREEP_COOLDOWN
				ButtonState_pen = nil
			end
		else
			ButtonState_pen = nil
		end
		
		if CustomData.Items.MAGICPEN.CreepSpewCooldown then 
			CustomData.Items.MAGICPEN.CreepSpewCooldown = CustomData.Items.MAGICPEN.CreepSpewCooldown - 1
		end
	end
	
	if Player:HasCollectible(Collectibles.NERVEPINCH) then
		for button = 0, 7 do
			if Input.IsActionTriggered(button, Player.ControllerIndex) then
				nervePinchButton = button
			end
		end
		
		if nervePinchButton and Input.IsActionPressed(nervePinchButton, Player.ControllerIndex) then
			CustomData.Items.NERVEPINCH.Hold = CustomData.Items.NERVEPINCH.Hold - 1
		else
			CustomData.Items.NERVEPINCH.Hold = NERVEPINCH_HOLD
		end
	end
	
	if Player:HasCollectible(Collectibles.BOTTOMLESSBAG) and Player:GetData()['BagUsed'] 
	and game:GetFrameCount() < CustomData.Items.BOTTOMLESSBAG.UseFrame + 100 then
		for i = 4, 7 do
			if Input.IsActionTriggered(i, Player.ControllerIndex) then
				Player:AnimateCollectible(Collectibles.BOTTOMLESSBAG, "HideItem", "PlayerPickupSparkle")
				if CustomData.Items.BOTTOMLESSBAG.TearCount > 1 then
					local shootVector = DIRECTION_VECTOR[Player:GetFireDirection()]
					
					for i = 1, CustomData.Items.BOTTOMLESSBAG.TearCount do
						extraOffset = Vector(math.random(-5,5), math.random(-5,5))
						local vacuumTear = Player:FireTear(Player.Position, shootVector * math.random(6, 15) + extraOffset, false, true, false, Player)
						vacuumTear.TearFlags = vacuumTear.TearFlags | TearFlags.TEAR_HOMING 
						local color = Color(1, 1, 1, 1, 0, 0, 0)
						color:SetColorize(1, 0, 1, 1)
						vacuumTear:SetColor(color, 0, 0, true, false)
					end
				end
				
				CustomData.Items.BOTTOMLESSBAG.TearCount = 0
				CustomData.Items.BOTTOMLESSBAG.UseFrame = 0
				Player:GetData()['BagUsed'] = false
			end
		end	
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, rplus.PostPlayerUpdate, 0)

						-- MC_POST_RENDER --										
						--------------------
function rplus:OnGameRender()
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	DisplayErrorMessage()
	--[[ rendering achievement papers
	if flagRenderPaper then RenderAchievementPapers() end
	--]]
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
			--render zealot hearts
		if (CustomData.Hearts.ZEALOT > 0 and Game():GetLevel():GetCurses () ~= LevelCurse.CURSE_OF_THE_UNKNOWN ) then
          	local zealotfull = CustomData.Hearts.ZEALOT / 2
          	local ishalf = (CustomData.Hearts.ZEALOT % 2 == 1)
          	local hearts = ((player:GetMaxHearts() + player:GetSoulHearts()) /2 ) + player:GetBoneHearts() + player:GetBrokenHearts()
          	local TopVector = Vector(0,0)
          	local HeartRenderOffset = Options.HUDOffset * Vector(20, 12)
          	
          	ZealotSprite = Sprite()
			ZealotSprite:Load("gfx/ui/ui_taintedhearts.anm2", true)
          	if (ishalf) then zealotfull = zealotfull + 1 end
          	for i=hearts+1, (hearts+zealotfull) do
            	if (i < 7) then
              		TopVector = Vector((i-1)*12 + 48, 12)
            	elseif (i < 13) then
              		TopVector = Vector((i-7)*12 + 48, 22)
            	else
             		TopVector = Vector((i-13)*12 + 48, 32)
            	end
            	if (not ishalf or i < hearts+zealotfull-1) then
              		ZealotSprite:SetFrame("ZealotFull", 0)
            	else
              		ZealotSprite:SetFrame("ZealotHalf", 0)
            	end
            	ZealotSprite:Render(TopVector+Vector(1, 1)+HeartRenderOffset, Vector.Zero, Vector.Zero)
         	end
        end 
        --render soiled hearts
        if (CustomData.Hearts.SOILED > 0 and Game():GetLevel():GetCurses () ~= LevelCurse.CURSE_OF_THE_UNKNOWN ) then
          	local soiledfull = CustomData.Hearts.SOILED / 2
          	local ishalf = (CustomData.Hearts.SOILED % 2 == 1)
          	local hearts = ((player:GetMaxHearts() + player:GetSoulHearts()) /2 ) + player:GetBoneHearts() + player:GetBrokenHearts() + (CustomData.Hearts.ZEALOT / 2)
          	local TopVector = Vector(0,0)
          	local HeartRenderOffset = Options.HUDOffset * Vector(20, 12)
          	SoiledSprite = Sprite()
			SoiledSprite:Load("gfx/ui/ui_taintedhearts.anm2", true)
          	if (ishalf) then soiledfull = soiledfull + 1 end
          	for i=hearts+1, (hearts+soiledfull) do
            	if (i < 7) then
              		TopVector = Vector((i-1)*12 + 48, 12)
            	elseif (i < 13) then
              		TopVector = Vector((i-7)*12 + 48, 22)
            	else
             		TopVector = Vector((i-13)*12 + 48, 32)
            	end
            	if (not ishalf or i < hearts+soiledfull-1) then
              		SoiledSprite:SetFrame("SoiledFull", 0)
            	else
              		SoiledSprite:SetFrame("SoiledHalf", 0)
            	end
            	SoiledSprite:Render(TopVector+Vector(1, 1)+HeartRenderOffset, Vector.Zero, Vector.Zero)
         	end
        end 
        --render dauntless heart
        if (CustomData.Hearts.DAUNTLESS > 0 and Game():GetLevel():GetCurses () ~= LevelCurse.CURSE_OF_THE_UNKNOWN ) then
          	local dauntlessfull = CustomData.Hearts.DAUNTLESS / 3
          	local isthird = (CustomData.Hearts.DAUNTLESS % 3 == 1)
          	local isthirds = (CustomData.Hearts.DAUNTLESS % 3 == 2)
          	local hearts = ((player:GetMaxHearts() + player:GetSoulHearts()) / 2 ) + player:GetBoneHearts() + player:GetBrokenHearts() + (CustomData.Hearts.ZEALOT / 2) + (CustomData.Hearts.SOILED / 2)
          	local TopVector = Vector(0,0)
          	local HeartRenderOffset = Options.HUDOffset * Vector(20, 12)
          	
          	DauntlessSprite = Sprite()
			DauntlessSprite:Load("gfx/ui/ui_taintedhearts.anm2", true)
			if isthird then dauntlessfull = dauntlessfull + 1 end
          	if isthirds then dauntlessfull = dauntlessfull + 1 end
          	for i=hearts+1, (hearts+dauntlessfull) do
            	if (i < 7) then
              		TopVector = Vector((i-1)*12 + 48, 12)
            	elseif (i < 13) then
              		TopVector = Vector((i-7)*12 + 48, 22)
            	else
             		TopVector = Vector((i-13)*12 + 48, 32)
            	end
            	if CustomData.Hearts.DAUNTLESS % 3 == 0 or i < hearts+dauntlessfull-1 then
              		DauntlessSprite:SetFrame("DauntlessFull", 0) 
            	elseif isthirds or i < hearts+dauntlessfull - 2  then 
              		DauntlessSprite:SetFrame("DauntlessTwoThirds", 0)
              	else 
              		DauntlessSprite:SetFrame("DauntlessThird", 0)
            	end
            	DauntlessSprite:Render(TopVector+Vector(1, 1)+HeartRenderOffset, Vector.Zero, Vector.Zero)
         	end
        end 
		if player:HasTrinket(Trinkets.GREEDSHEART) and not isInGhostForm(player) then
			CoinHeartSprite = Sprite()
			
			CoinHeartSprite:Load("gfx/ui/ui_coinhearts.anm2", true)
			if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= LevelCurse.CURSE_OF_THE_UNKNOWN then
				CoinHeartSprite:SetFrame(CustomData.Trinkets.GREEDSHEART, 0)	-- custom data value is either "CoinHeartEmpty" or "CoinHeartFull"
			else
				CoinHeartSprite:SetFrame("CoinHeartUnknown", 0)
			end
			
			-- since 1.7.6 patch, it is possible to find out whether the player is in full screen and the value of hud offset. cool!
			HeartRenderPos = Vector(122, 11)
			HeartRenderOffset = Options.HUDOffset * Vector(20, 12)
			CoinHeartSprite:Render(HeartRenderPos + HeartRenderOffset, Vector.Zero, Vector.Zero)
		end
		
		if player:HasTrinket(Trinkets.ANGELSCROWN) and room:GetType() == RoomType.ROOM_TREASURE 
		and not room:IsMirrorWorld() then
			FloorPiece:GetSprite().Scale = Vector(0.25, 0.25)
			FloorPiece:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
			FloorPiece:GetSprite():Load("gfx/backdrop/angel_treasure_room_backdrops.anm2", true)
			FloorPiece:GetSprite():Play("Floor_" .. room:GetRoomShape(), true)
			
			WallPiece:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)
			WallPiece:GetSprite():Load("gfx/backdrop/angel_treasure_room_backdrops.anm2", true)
			WallPiece:GetSprite():Play("Walls_" .. room:GetRoomShape(), true)
		end
		
		if player:HasCollectible(Collectibles.CEILINGSTARS) and (room:GetType() == 18 or room:GetType() == 19 or level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()) then
			if not StarCeiling then StarCeiling = Sprite() end
			StarCeiling:Load("gfx/ui/ui_starceiling.anm2", true)
			StarCeiling:SetFrame("Idle", game:GetFrameCount() % 65)
			StarCeiling.Scale = Vector(1.5, 1.5)
			StarCeiling:Render(Vector(300, 200), Vector.Zero, Vector.Zero)
		end
		
		if player:HasCollectible(Collectibles.DNAREDACTOR) then
			for _, pickupPill in pairs(Isaac.FindInRadius(player.Position, 150, EntityPartition.PICKUP)) do
				if pickupPill.Variant == 70 then
					DNAPillIcon.Scale = Vector(0.5, 0.5)
					
					DNAPillIcon:SetFrame("pill_" .. tostring(pickupPill.SubType), 0)
					DNAPillIcon:Render(Isaac.WorldToScreen(pickupPill.Position + Vector(15, -15)), Vector.Zero, Vector.Zero)
				end
			end
		end
		
		if player:HasCollectible(Collectibles.REDMAP) then
			RedMapIcon:SetFrame("RedMap", 0)
			MapRenderPos = Vector(10, 190)
			MapRenderOffset = Options.HUDOffset * Vector(20, 12)
			RedMapIcon:Render(MapRenderPos + MapRenderOffset, Vector.Zero, Vector.Zero)
		end
		
		if CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown then
			if CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown <= 0 
			and CustomData.Items.ENRAGEDSOUL.SoulLaunchCooldown >= -40 then
				SoulIcon:Update()
				SoulIcon:Render(Isaac.WorldToScreen(player.Position + Vector(25, -45)), Vector.Zero, Vector.Zero)
			end
		end
		
		if CustomData.Items.MAGICPEN.CreepSpewCooldown then
			if CustomData.Items.MAGICPEN.CreepSpewCooldown <= 0 
			and CustomData.Items.MAGICPEN.CreepSpewCooldown >= -34 then
				PenIcon:Update()
				PenIcon:Render(Isaac.WorldToScreen(player.Position + Vector(25, -45)), Vector.Zero, Vector.Zero)
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_RENDER, rplus.OnGameRender)

						-- MC_PRE_USE_ITEM --											
						---------------------				
function rplus:PreUseItem(ItemUsed, RNG, Player, UseFlags, ActiveSlot, CustomVarData)
	-- helper for Torn Page	(if you want to override the book's certain gimmick, not just add something)
	if Player:HasTrinket(Trinkets.TORNPAGE) then
		-- book of revelations doesn't cause harbingers to spawn
		if ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS then
			Player:AddSoulHearts(2)
			Player:AnimateCollectible(ItemUsed, "Pickup", "PlayerPickupSparkle")
			return true
		-- satanic bible doesn't cause devil deal items to appear in boss rooms
		elseif ItemUsed == CollectibleType.COLLECTIBLE_SATANIC_BIBLE then
			Player:AddBlackHearts(2)
			Player:AnimateCollectible(ItemUsed, "Pickup", "PlayerPickupSparkle")
			return true
		-- book of sin has a small chance to spawn an item instead of pickup
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SIN and math.random(100) == 1 then
			Isaac.Spawn(5, 100, 0, Isaac.GetFreeNearPosition(Player.Position, 10), Vector.Zero, nil)
			Player:AnimateCollectible(ItemUsed, "Pickup", "PlayerPickupSparkle")
			return true
		-- anarchist cookbook spawns red bombs instead of troll bombs
		elseif ItemUsed == CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK then
			for s = 1, 6 do
				Isaac.Spawn(5, 41, 0, game:GetRoom():GetRandomPosition(10), Vector.Zero, nil)
			end
			Player:AnimateCollectible(ItemUsed, "Pickup", "PlayerPickupSparkle")
			return true
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, rplus.PreUseItem)

						-- MC_ENTITY_TAKE_DMG --									
						------------------------
function rplus:EntityTakeDmg(Entity, Amount, Flags, Source, CDFrames)	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(Collectibles.MAGICPEN) and Source.Entity and Source.Entity.Type == 1000 and Source.Entity.SubType == 4 then
			if math.random(100) < 4 then 
				local Flags = {
					EntityFlag.FLAG_POISON, 
					EntityFlag.FLAG_SLOW, 
					EntityFlag.FLAG_CHARM, 
					EntityFlag.FLAG_CONFUSION, 
					EntityFlag.FLAG_FEAR, 
					EntityFlag.FLAG_BURN
				}
				
				Entity:AddEntityFlags(Flags[math.random(#Flags)])
			end
			return false
		end
		
		if player:HasTrinket(Trinkets.CHALKPIECE) and Source.Entity and Source.Entity.Type == 1000 and Source.Entity.SubType == 5 then
			Entity.Velocity = Entity.Velocity:Resized(-2.5)
			return false
		end
		
		if player:HasCollectible(Collectibles.TEMPERTANTRUM) then 
			if Entity.Type == 1 and math.random(100) <= SUPERBERSERK_ENTER_CHANCE then
				player:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK, true, true, false, true, -1)
				CustomData.Items.TEMPERTANTRUM.SuperBerserkState = true
			end
		end
		
		if CustomData.Items.TEMPERTANTRUM.SuperBerserkState and Entity:IsVulnerableEnemy() and not Entity:IsBoss() and math.random(100) <= SUPERBERSERK_DELETE_CHANCE then
			table.insert(CustomData.Items.TEMPERTANTRUM.ErasedEnemies, Entity.Type)
		end
		
		if player:HasTrinket(Trinkets.JUDASKISS) and Entity.Type == 1 
		and Soruce.Entity and Source.Entity:IsActiveEnemy(false) then
			Source.Entity:AddEntityFlags(EntityFlag.FLAG_BAITED)
		end
		-- take damage with custom hearts
		if CustomData.Hearts.ZEALOT > 0 and not isInGhostForm(Player) and CustomData.Hearts.SOILED==0 and CustomData.Hearts.DAUNTLESS==0 then
			if not isSelfDamage(Flags, "taintedhearts") then
				CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT - Amount
				if CustomData.Hearts.ZEALOT < 0 then 
					CustomData.Hearts.ZEALOT = 0
				end
				Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				return false
			elseif isSelfDamage(Flags, "taintedhearts") and Player:GetHearts() == 0 then 
				CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT - Amount
				if CustomData.Hearts.ZEALOT < 0 then 
					CustomData.Hearts.ZEALOT = 0
				end
				Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				return false
			else 
				return true
			end
		end


		if CustomData.Hearts.SOILED > 0 and not isInGhostForm(Player) and CustomData.Hearts.DAUNTLESS==0 then
			if not isSelfDamage(Flags, "taintedhearts") then
				CustomData.Hearts.SOILED = CustomData.Hearts.SOILED - Amount
				if CustomData.Hearts.SOILED < 0 then 
					CustomData.Hearts.SOILED = 0
				end
				Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				return false
			elseif isSelfDamage(Flags, "taintedhearts") and Player:GetHearts() == 0 then 
				CustomData.Hearts.SOILED = CustomData.Hearts.SOILED - Amount
				if CustomData.Hearts.SOILED < 0 then 
					CustomData.Hearts.SOILED = 0
				end
				Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				return false
			else 
				return true
			end
		end

		if CustomData.Hearts.DAUNTLESS > 0 and not isInGhostForm(Player) then
			if not isSelfDamage(Flags, "taintedhearts") then
				CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS - Amount
				if CustomData.Hearts.DAUNTLESS < 0 then 
					CustomData.Hearts.DAUNTLESS = 0
				end
				Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				return false
			elseif isSelfDamage(Flags, "taintedhearts") and Player:GetHearts() == 0 then 
				CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS - Amount
				if CustomData.Hearts.DAUNTLESS < 0 then 
					CustomData.Hearts.DAUNTLESS = 0
				end
				Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				return false
			else 
				return true
			end
		end
		
		if player:HasCollectible(Collectibles.BLACKDOLL) and ABSepNumber then
			for i = 1, #EntitiesGroupA do 
				if Entity:GetData() == EntitiesGroupA[i]:GetData() and EntitiesGroupB[i] and Source.Entity and Source.Entity.Type < 9 then 
					EntitiesGroupB[i]:TakeDamage(Amount * 0.6, 0, EntityRef(Entity), 0)
				end 
			end
			for i = 1, #EntitiesGroupB do 
				if Entity:GetData() == EntitiesGroupB[i]:GetData() and EntitiesGroupA[i] and Source.Entity and Source.Entity.Type < 9 then 
					EntitiesGroupA[i]:TakeDamage(Amount * 0.6, 0, EntityRef(Entity), 0)
				end 
			end
		end
		
		if player:HasTrinket(Trinkets.GREEDSHEART) and CustomData.Trinkets.GREEDSHEART == "CoinHeartFull" and Entity.Type == 1 
		and not isInGhostForm(player) and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isSelfDamage(Flags, "greedsheart") then
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 2, false, 1, 0)
			CustomData.Trinkets.GREEDSHEART = "CoinHeartEmpty"
			Entity:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
			return false
		end
		
		if player:HasCollectible(Collectibles.CEREMDAGGER) and Source.Entity and Source.Entity.Type == 2 and Source.Entity.Variant == TearVariants.CEREMDAGGER 
		and Entity:IsActiveEnemy(true) and Entity:IsVulnerableEnemy() then
			Entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			sfx:Play(SoundEffect.SOUND_KNIFE_PULL, 1, 2, false, 1, 0)
			return false
		end
		
		if player:HasCollectible(Collectibles.BIRDOFHOPE) and CustomData and CustomData.Items.BIRDOFHOPE.BirdCaught == false and Entity.Type == 1 then
			return false
		end
		
		if player:HasTrinket(Trinkets.MAGICSWORD, false) and Entity.Type == 1 and not player:HasTrinket(TrinketType.TRINKET_DUCT_TAPE) 
		and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE and not isSelfDamage(Flags) then
			sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 2, false, 1, 0)
			player:TryRemoveTrinket(Trinkets.MAGICSWORD)
			Isaac.Spawn(5, 350, Trinkets.WAITNO, player.Position, Vector.Zero, nil)
		end
		
		if player:HasTrinket(Trinkets.EDENSLOCK) and Entity.Type == 1 
		and not isSelfDamage(Flags) then
			local freezePreventChecker = 0
				
			repeat
				ID = player:GetDropRNG():RandomInt(728) + 1
				freezePreventChecker = freezePreventChecker + 1
			until (player:HasCollectible(ID, true)
			and Isaac.GetItemConfig():GetCollectible(ID).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
			and Isaac.GetItemConfig():GetCollectible(ID).Type % 3 == 1)	-- passive or familiar (1 or 4)
			or freezePreventChecker == 10000
			
			if freezePreventChecker < 10000 then
				player:RemoveCollectible(ID, true, -1, true)
			else 
				return true
			end
			
			repeat 
				newID = GetUnlockedVanillaCollectible(true)
			until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
			player:AddCollectible(newID, 0, false, -1, 0)
			
			sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 2, false, 1, 0)
		end
		
		if player:HasCollectible(Collectibles.REDBOMBER) and
		Entity.Type == 1 and Flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
			return false
		end
		
		if Entity.Type == 1 and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isInGhostForm(player) and CustomData.Items.BLOODVESSEL.DamageFlag == false 
		and not isSelfDamage(Flags, "bloodvessel") then
			for i = 1, #Collectibles.BLOODVESSELS do
				if Entity:ToPlayer():HasCollectible(Collectibles.BLOODVESSELS[i]) then
					if i == 7 then
						CustomData.Items.BLOODVESSEL.DamageFlag = true
						Entity:TakeDamage(7, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(Entity), 18)
						Entity:ToPlayer():RemoveCollectible(Collectibles.BLOODVESSELS[i])
						Entity:ToPlayer():AddCollectible(Collectibles.BLOODVESSELS[1])
						CustomData.Items.BLOODVESSEL.DamageFlag = false
					else
						Entity:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 18)
						Entity:ToPlayer():RemoveCollectible(Collectibles.BLOODVESSELS[i])
						Entity:ToPlayer():AddCollectible(Collectibles.BLOODVESSELS[i+1])
					end
					return false
				end
			end
		end
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB) then
			for _, chest in pairs(Isaac.FindByType(5, PickUps.SCARLETCHEST, -1, false, false)) do
				if chest.SubType == 0 or chest.SubType == 2 then
					openScarletChest(chest)
					break
				end
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, rplus.EntityTakeDmg)

						-- MC_POST_NPC_INIT --											
						-----------------------
function rplus:OnNPCInit(NPC)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasTrinket(Trinkets.BABYSHOES) then
			NPC.Size = NPC.Size * 0.8
			NPC.Scale = NPC.Scale * 0.8
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NPC_INIT, rplus.OnNPCInit)

						-- MC_POST_NPC_DEATH --											
						-----------------------
function rplus:OnNPCDeath(NPC)
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasTrinket(Trinkets.KEYTOTHEHEART) and math.random(100) <= HEARTKEY_CHANCE * player:GetTrinketMultiplier(Trinkets.KEYTOTHEHEART) 
		and NPC.MaxHitPoints >= 10 then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickUps.FLESHCHEST, 0, NPC.Position, NPC.Velocity, nil)
		end
		
		if player:HasCollectible(Collectibles.CHERRYFRIENDS) and math.random(100) <= CHERRY_SPAWN_CHANCE then
			Isaac.Spawn(3, Familiars.CHERRY, 1, NPC.Position, Vector.Zero, nil)
			sfx:Play(SoundEffect.SOUND_BABY_HURT, 1, 2, false, 1, 0)
		end
		
		if player:HasCollectible(Collectibles.CEREMDAGGER) and not NPC:IsBoss() and NPC:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
			Isaac.Spawn(5, 300, PocketItems.SACBLOOD, NPC.Position, Vector.Zero, nil)
		end
		
		if player:HasCollectible(Collectibles.GUSTYBLOOD) and NPC:IsEnemy() and CustomData.Items.GUSTYBLOOD.CurrentSpeed < 10 then
			CustomData.Items.GUSTYBLOOD.CurrentTears = CustomData.Items.GUSTYBLOOD.CurrentTears + 1
			CustomData.Items.GUSTYBLOOD.CurrentSpeed = CustomData.Items.GUSTYBLOOD.CurrentSpeed + 1
			player:SetColor(Color(1, 0.5, 0.5, 1, 0, 0, 0), 15, 1, false, false)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
		end
		
		if player:HasCollectible(Collectibles.KEEPERSPENNY) and room:GetType() == RoomType.ROOM_SHOP 
		and NPC.Type == EntityType.ENTITY_GREED then
			RNGobj:SetSeed(Random() + 1, 1)
			local numNewItems = RNGobj:RandomInt(2) + 3
			
			if numNewItems == 3 then
				V = {Vector(320, 280), Vector(160, 280), Vector(480, 280)}
			else
				V = {Vector(160, 280), Vector(480, 280), Vector(120, 360), Vector(520, 360)}
			end
			
			for i = 1, numNewItems do
				local pool = KEEPERSPENNY_ITEMPOOLS[math.random(#KEEPERSPENNY_ITEMPOOLS)]
				local Item = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(pool, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), V[i], Vector.Zero, nil):ToPickup()
				Item.Price = 15
				Item.ShopItemId = -13 * i
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, rplus.OnNPCDeath)

						-- MC_POST_PICKUP_INIT -- 										
						-------------------------
function rplus:OnPickupInit(Pickup)	
	local room = game:GetRoom()
	local stage = game:GetLevel():GetStage()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if (Pickup:GetSprite():IsPlaying("Appear") or Pickup:GetSprite():IsPlaying("AppearFast")) 
		and Pickup:GetSprite():GetFrame() == 0 then
			if player:HasTrinket(Trinkets.BASEMENTKEY) and Pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST 
			and math.random(100) <= BASEMENTKEY_CHANCE * player:GetTrinketMultiplier(Trinkets.BASEMENTKEY) 
			and room:GetType() ~= RoomType.ROOM_CHALLENGE then
				Pickup:Morph(5, PickupVariant.PICKUP_OLDCHEST, 0, true, true, false)
			end
			
			local CoinSubTypesByVal = {1, 4, 6, 2, 3, 5, 7} -- penny, doublepack, sticky nickel, nickel, dime, lucky penny, golden penny
			if Pickup.Variant == 20 and Pickup.SubType ~= 7 and player:HasTrinket(Trinkets.SLEIGHTOFHAND) 
			and math.random(100) <= SLEIGHTOFHAND_UPGRADE_CHANCE * player:GetTrinketMultiplier(Trinkets.SLEIGHTOFHAND) then
				sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 2, false, 1, 0)
				for i = 1, #CoinSubTypesByVal do
					if CoinSubTypesByVal[i] == Pickup.SubType then CurType = i break end
				end
				Pickup:Morph(5, 20, CoinSubTypesByVal[CurType + 1], true, true, false)
			end
			
			if math.random(100) <= FLESHCHEST_REPLACE_CHANCE 
			and (Pickup.Variant == PickupVariant.PICKUP_SPIKEDCHEST or Pickup.Variant == PickupVariant.PICKUP_MIMICCHEST or Pickup.Variant == PickupVariant.PICKUP_REDCHEST) 
			and room:GetType() ~= RoomType.ROOM_CHALLENGE then
				Pickup:Morph(5, PickUps.FLESHCHEST, 0, true, true, false)
				sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			end
			
			-- TAINTED HEARTS REPLACEMENT --
			if Pickup.Variant == 10 then
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomFloat() * 100
				local st = Pickup.SubType
				
				if st == HeartSubType.HEART_FULL or st == HeartSubType.HEART_HALF then
					-- 1% broken heart
					if roll < 1 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_BROKEN, true, true, false)
					-- 1% enigma heart
					elseif roll < 2 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_ENIGMA, true, true, false) end
				elseif st == HeartSubType.HEART_SOUL then
					-- 15% fettered heart
					if roll < 15 and stage > 1 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_FETTERED, true, true, false) 
					elseif roll < 30 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_ZEALOT, true, true, false) 
					elseif roll < 45 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_DAUNTLESS, true, true, false) end
				elseif st == HeartSubType.HEART_ETERNAL then
					
				elseif st == HeartSubType.HEART_DOUBLEPACK then
					-- 25% hoarded heart
					if roll < 25 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_HOARDED, true, true, false) end
				elseif st == HeartSubType.HEART_BLACK then
					-- 30% deserted heart
					if roll < 30 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_DESERTED, true, true, false)
					-- 25% benighted heart
					elseif roll < 55 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_BENIGHTED, true, true, false) end
				elseif st == HeartSubType.HEART_GOLDEN then
					
				elseif st == HeartSubType.HEART_HALF_SOUL then
					
				elseif st == HeartSubType.HEART_SCARED then
					
				elseif st == HeartSubType.HEART_BLENDED then
					-- 30% deserted heart
					if roll < 30 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_DESERTED, true, true, false) end
				elseif st == HeartSubType.HEART_BONE then
				
				elseif st == HeartSubType.HEART_ROTTEN then
					elseif roll < 15 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_SOILED, true, true, false) 
				end
				
				-- 2% capricious heart
				if roll < 2 then Pickup:Morph(5, 10, PickUps.TaintedHearts.HEART_CAPRICIOUS, true, true, false) end
			end
		end
	end
		
	if (Pickup.Variant == PickUps.FLESHCHEST or Pickup.Variant == PickUps.BLACKCHEST or Pickup.Variant == PickUps.SCARLETCHEST)
	and Pickup.SubType == 1 and not Pickup:GetData()["IsInRoom"] then
		Pickup:Remove()
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, rplus.OnPickupInit)

						-- MC_PRE_PICKUP_COLLISION --									
						-----------------------------
function rplus:PickupCollision(Pickup, Collider, _)	
	if not Collider:ToPlayer() then return end
	local player = Collider:ToPlayer()
	local totalhealth = player:GetMaxHearts() + player:GetSoulHearts() + (player:GetBoneHearts() * 2) + (player:GetBrokenHearts()*2)+CustomData.Hearts.ZEALOT+CustomData.Hearts.SOILED+math.floor(CustomData.Hearts.DAUNTLESS*2/3)
	if player:GetPlayerType() == 1 and player:HasCollectible(CollectibleType.BIRTHRIGHT) then --birthright for maggy gives you ability to have 18 hearts instead of 12
		maxhealth = 36
	else maxhealth = 24 end
	
	if Pickup.Variant == PickUps.FLESHCHEST and Pickup.SubType == 0 then
		-- subtype 1: opened chest (need to remove)
		Pickup.SubType = 1
		-- setting some data for pickup, because it is deleted on entering a new room, and the pickup is removed as well
		Pickup:GetData()["IsInRoom"] = true
		Pickup:GetSprite():Play("Open")
		sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
		Collider:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(Pickup), 24)
		RNGobj:SetSeed(Random() + 1, 1)
		local DieRoll = RNGobj:RandomFloat()
		
		if DieRoll < 0.15 then
			local freezePreventChecker = 0
			
			repeat
				Item = ItemPools.FLESHCHEST[math.random(#ItemPools.FLESHCHEST)]
				freezePreventChecker = freezePreventChecker + 1
			until IsCollectibleUnlocked(Item) or freezePreventChecker == 1000
			
			if freezePreventChecker < 1000 then
				local FLESHCHESTPedestal = Isaac.Spawn(5, 100, Item, Pickup.Position, Vector(0, 0), Pickup)
				FLESHCHESTPedestal:GetSprite():ReplaceSpritesheet(5,"gfx/items/fleshchest_itemaltar.png") 
				FLESHCHESTPedestal:GetSprite():LoadGraphics()
			else 
				EntityNPC.ThrowSpider(Pickup.Position, Pickup, Pickup.Position + Vector.FromAngle(math.random(360)) * 200, false, 0) 
			end
			
			Pickup:Remove()
		elseif DieRoll < 0.85 then
			RNGobj:SetSeed(Pickup.DropSeed, 1)
			local NumOfPickups = RNGobj:RandomInt(4) + 1 -- 1 to 4 pickups
			
			for i = 1, NumOfPickups do
				local variant = nil
				local subtype = nil
				
				if math.random(100) < 50 then
					local heartSubTypes = {1, 2, 5, 8, 9, 11, 12}
					variant = 10
					subtype = heartSubTypes[math.random(#heartSubTypes)]
				else
					variant = 70
					subtype = 0
				end
				Isaac.Spawn(5, variant, subtype, Pickup.Position, Vector.FromAngle(math.random(360)) * 5, Pickup)
			end
		else
			EntityNPC.ThrowSpider(Pickup.Position, Pickup, Pickup.Position + Vector.FromAngle(math.random(360)) * 200, false, 0)
		end
	end
	
	if player:HasTrinket(Trinkets.GREEDSHEART) and CustomData.Trinkets.GREEDSHEART == "CoinHeartEmpty" and Pickup.Variant == 20 and Pickup.SubType ~= 6 
	and not isInGhostForm(player) 
	-- if the player's Keeper, they should be at full health to gain a new coin heart
	and (player:GetHearts() == player:GetMaxHearts() or (player:GetPlayerType() ~= 14 and player:GetPlayerType() ~= 33)) then
		player:AddCoins(-1)
		CustomData.Trinkets.GREEDSHEART = "CoinHeartFull"
	end
	
	-- this monster is able to 100% (so far) detect whether we buy something and whether we don't
	-- mad? cry about it
	if player:HasCollectible(Collectibles.TWOPLUSONE) 
	and Pickup.Price > -6 and Pickup.Price ~= 0 	-- this pickup costs something
	and not player:IsHoldingItem()		-- we're not holding another pickup right now
	then
		if (Pickup.Price == -1 and player:GetMaxHearts() >= 2)
		or (Pickup.Price == -2 and player:GetMaxHearts() >= 4)
		or (Pickup.Price == -3 and player:GetSoulHearts() >= 6)
		or (Pickup.Price == -4 and player:GetMaxHearts() >= 2 and player:GetSoulHearts() >= 4)	-- this devil deal is affordable
		then
			CustomData.Items.TWOPLUSONE.ItemsBought_HEARTS = CustomData.Items.TWOPLUSONE.ItemsBought_HEARTS + 1
		elseif Pickup.Price > 0 and player:GetNumCoins() >= Pickup.Price	-- this shop item is affordable
		and not (Pickup.Variant == 90 and not (player:NeedsCharge(0) or player:NeedsCharge(1) or player:NeedsCharge(2)))
		and not (Pickup.Variant == 10 and Pickup.SubType == 1 and not player:CanPickRedHearts())
		and not (Pickup.Variant == 10 and Pickup.SubType == 3 and not player:CanPickSoulHearts())
		then
			if CustomData.Items.TWOPLUSONE.ItemsBought_COINS == 2 then
				CustomData.Items.TWOPLUSONE.ItemsBought_COINS = 0
				for _, pickup in pairs(Isaac.FindByType(5, -1, -1, false, false)) do
					if pickup:ToPickup().Price == 1 then
						pickup:ToPickup().AutoUpdatePrice = true
					end
				end
			else
				CustomData.Items.TWOPLUSONE.ItemsBought_COINS = CustomData.Items.TWOPLUSONE.ItemsBought_COINS + 1
			end
		end
	end
	if Pickup.Variant == 10 and (Pickup.SubType == 3 or Pickup.SubType == 6) then --can't pick up blue or black hearts with 12 hearts(including custom hearts)
		if totalhealth>maxhealth-1 then 
			return false
		end
	end
	if Pickup.Variant == 10 and player:CanPickRedHearts()  
	and (Pickup.SubType == 1 or Pickup.SubType == 2 or Pickup.SubType == 5 or Pickup.SubType == 12) then
		if ((game:GetFrameCount() - CustomData.Pills.YUCK.UseFrame) <= 900 and player:GetData()['usedYuck'])
		or ((game:GetFrameCount() - CustomData.Pills.YUCK.UseFrame) <= 1800 and player:GetData()['usedHorseYuck']) then
			for i = 1, math.random(3) do 
				Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector.Zero, nil) 
			end
		else
			player:GetData()['usedHorseYuck'] = false
			player:GetData()['usedYuck'] = false
		end
		
		if ((game:GetFrameCount() - CustomData.Pills.YUM.UseFrame) <= 900 and player:GetData()['usedYum'])
		or ((game:GetFrameCount() - CustomData.Pills.YUM.UseFrame) <= 1800 and player:GetData()['usedHorseYum']) then
			YumStat = math.random(4)
			if YumStat == 1 then -- damage
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				CustomData.Pills.YUM.NumDamage = CustomData.Pills.YUM.NumDamage + 1
				player:GetData()['GetYumDamage'] = true						
			elseif YumStat == 2 then -- tears
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
				CustomData.Pills.YUM.NumTears = CustomData.Pills.YUM.NumTears + 1
				player:GetData()['GetYumTears'] = true						
			elseif YumStat == 3 then -- shotspeed
				player:AddCacheFlags(CacheFlag.CACHE_RANGE)
				CustomData.Pills.YUM.NumRange = CustomData.Pills.YUM.NumRange + 1
				player:GetData()['GetYumRange'] = true
			elseif YumStat == 4 then -- luck
				player:AddCacheFlags(CacheFlag.CACHE_LUCK)
				CustomData.Pills.YUM.NumLuck = CustomData.Pills.YUM.NumLuck + 1
				player:GetData()['GetYumLuck'] = true
			end
			player:EvaluateItems()
		else
			player:GetData()['usedHorseYum'] = false
			player:GetData()['usedYum'] = false
		end
	end
	
	if Pickup.Variant == 10 and Pickup.SubType >= PickUps.TaintedHearts.HEART_BROKEN and Pickup.SubType <= PickUps.TaintedHearts.HEART_DESERTED then
		-- tainted hearts
		if Pickup.SubType == PickUps.TaintedHearts.HEART_BROKEN then
			player:AddMaxHearts(2)
			player:AddHearts(2)
			player:AddBrokenHearts(1)
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
		end
		if player:GetPlayerType() ~= 10 and player:GetPlayerType() ~= 31 then -- the lost can't get hearts that change ui
			if Pickup.SubType == PickUps.TaintedHearts.HEART_ZEALOT then			
				if totalhealth<maxhealth then 
					if totalhealth % 2 == 0 or CustomData.Hearts.ZEALOT % 2 == 1 or CustomData.Hearts.SOILED % 2 == 1 then 
            			CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT + 2
            		elseif totalhealth == maxhealth - 1 and player:GetMaxHearts()~=maxhealth-2 then 
            			player:AddSoulHearts(-1)
            			CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT + 2
            		elseif player:GetSoulHearts() % 2 == 1 or player:GetBlackHearts() % 2 == 1 then 
                		player:AddSoulHearts(1)
               	 		CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT + 1
               		end
            	elseif totalhealth == maxhealth and player:GetSoulHearts()>0 and player:GetMaxHearts()~=maxhealth then 
            		player:AddSoulHearts(-2)
            		CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT + 2
        		else return false end
			end

			if Pickup.SubType == PickUps.TaintedHearts.HEART_SOILED then			
				if totalhealth<maxhealth then 
					if totalhealth % 2 == 0 or CustomData.Hearts.SOILED % 2 == 1 then 
            			CustomData.Hearts.SOILED = CustomData.Hearts.SOILED + 2
            		elseif totalhealth == maxhealth - 1 and player:GetMaxHearts()~=maxhealth-2 then 
            			player:AddSoulHearts(-1)
            			CustomData.Hearts.SOILED = CustomData.Hearts.SOILED + 2
            		elseif player:GetSoulHearts() % 2 == 1 or player:GetBlackHearts() % 2 == 1 then 
                		player:AddSoulHearts(1)
               	 		CustomData.Hearts.SOILED = CustomData.Hearts.SOILED + 1
               		elseif CustomData.Hearts.ZEALOT % 2 == 1 then 
               			CustomData.Hearts.SOILED = CustomData.Hearts.SOILED + 1
               			CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT + 1
               		end
            	elseif totalhealth == maxhealth and player:GetSoulHearts()>0 and player:GetMaxHearts()~=maxhealth then 
            		player:AddSoulHearts(-2)
            		CustomData.Hearts.SOILED = CustomData.Hearts.SOILED + 2
        		else return false end
			end

			if Pickup.SubType == PickUps.TaintedHearts.HEART_DAUNTLESS then
				if totalhealth<maxhealth then 
					if totalhealth % 2 == 0 or CustomData.Hearts.DAUNTLESS % 3 == 1 then 
            			CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS + 3
            		elseif totalhealth == maxhealth - 1 then 
            			player:AddSoulHearts(-1)
            			CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS + 3
            		elseif player:GetSoulHearts() % 2 == 1 or player:GetBlackHearts() % 2 == 1 then 
                		player:AddSoulHearts(1)
               	 		CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS + 2
               		elseif CustomData.Hearts.ZEALOT % 2 == 1 then 
               			CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS + 2
               			CustomData.Hearts.ZEALOT = CustomData.Hearts.ZEALOT + 1
               		elseif CustomData.Hearts.SOILED % 2 == 1 then 
               			CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS + 2
               			CustomData.Hearts.SOILED = CustomData.Hearts.SOILED + 1
               		end
            	elseif totalhealth == maxhealth and player:GetSoulHearts()>0 and player:GetMaxHearts()~=maxhealth then 
            		player:AddSoulHearts(-2)
            		CustomData.Hearts.DAUNTLESS = CustomData.Hearts.DAUNTLESS + 3
        		else return false end
			end
		end
		if Pickup.SubType == PickUps.TaintedHearts.HEART_HOARDED then
			if player:CanPickRedHearts() then
				player:AddHearts(8)
				sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == PickUps.TaintedHearts.HEART_BENIGHTED then
			if player:CanPickBlackHearts() then
				player:AddBlackHearts(2)
				player:GetData()['NumPickedBenightedHearts'] = player:GetData()['NumPickedBenightedHearts'] or 0
				player:GetData()['NumPickedBenightedHearts'] = player:GetData()['NumPickedBenightedHearts'] + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
				sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == PickUps.TaintedHearts.HEART_ENIGMA then
			player:AddMaxHearts(2)
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
		end
		
		if Pickup.SubType == PickUps.TaintedHearts.HEART_CAPRICIOUS then
			for i = 1, 3 do 
				Isaac.Spawn(5, 10, math.random(12), Pickup.Position, Vector.FromAngle(math.random(360)) * 3, nil)
			end
			sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 2, false, 1, 0)
		end
		
		if Pickup.SubType == PickUps.TaintedHearts.HEART_FETTERED then
			if (player:GetNumKeys() > 0 or player:HasGoldenKey()) and player:CanPickSoulHearts() then
				player:AddSoulHearts(3)
				if not player:HasGoldenKey() then player:AddKeys(-1) end
				sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 2, false, 1, 0)
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == PickUps.TaintedHearts.HEART_DESERTED then
			if player:CanPickRedHearts() then player:AddHearts(1) sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0) elseif player:CanPickBlackHearts() then player:AddBlackHearts(1) sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0) end
			if player:CanPickRedHearts() then player:AddHearts(1) sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0) elseif player:CanPickBlackHearts() then player:AddBlackHearts(1) sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0) end
		end
		
		Pickup:Remove()
	end
	
	if Pickup.Variant == PickUps.BLACKCHEST and Pickup.SubType == 0 then		
		-- setting some data for pickup, because it is deleted on entering a new room, and the pickup is removed as well
		Pickup:GetData()["IsInRoom"] = true
		Pickup:GetSprite():Play("Open")
		sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
		player:TakeDamage(1, 0, EntityRef(Pickup), 24)
		RNGobj:SetSeed(Random() + 1, 1)
		local DieRoll = RNGobj:RandomFloat()
		
		if DieRoll < 0.1 then
			local freezePreventChecker = 0
			
			repeat
				Item = ItemPools.BLACKCHEST[math.random(#ItemPools.BLACKCHEST)]
				freezePreventChecker = freezePreventChecker + 1
			until IsCollectibleUnlocked(Item) or freezePreventChecker == 1000
			
			if freezePreventChecker < 1000 then
				local BlackChestPedestal = Isaac.Spawn(5, 100, Item, Pickup.Position, Vector(0, 0), Pickup)
				BlackChestPedestal:GetSprite():ReplaceSpritesheet(5,"gfx/items/blackchest_itemaltar.png") 
				BlackChestPedestal:GetSprite():LoadGraphics()
			end
			
			Pickup:Remove()
		elseif DieRoll < 0.75 then
			-- subtype 2: opened chest with consumables (need to close again later)
			Pickup.SubType = 2
			Pickup:GetData()['OpenFrame'] = game:GetFrameCount()
				
			Isaac.Spawn(5, PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_BLACK, Pickup.Position, Vector.FromAngle(math.random(360)) * 5, Pickup)
			if math.random(100) <= 33 then Isaac.Spawn(5, PickupVariant.PICKUP_GRAB_BAG, SackSubType.SACK_BLACK, Pickup.Position, Vector.FromAngle(math.random(360)) * 5, Pickup) end
		else
			-- subtype 1: opened chest with nothing (need to remove)
			Pickup.SubType = 1		
		end
	end
	
	if Pickup.Variant == PickUps.SCARLETCHEST and (Pickup.SubType == 0 or Pickup.SubType == 2) then
		if not canOpenScarletChests(player) then return false end
		
		if Pickup.SubType == 2 or not player:HasTrinket(TrinketType.TRINKET_CRYSTAL_KEY) then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_RED_KEY) and player:GetActiveCharge(0) >= 4 then
				player:DischargeActiveItem(0)
			elseif player:GetCard(0) == Card.CARD_CRACKED_KEY then
				player:SetCard(0, 0)
			else
				return false
			end
		elseif Pickup.SubType == 0 then
			if math.random(100) >= 100 / (4 - player:GetTrinketMultiplier(TrinketType.TRINKET_CRYSTAL_KEY)) then
				Pickup.SubType = 2
				return false
			end
		else
			return false
		end
		
		openScarletChest(Pickup)
	end
	
	if player:HasCollectible(Collectibles.STARGAZERSHAT) 
	and Pickup.Variant == 10 then
		local HatSlot = 0
		local addCharges
	
		if Pickup.SubType == HeartSubType.HEART_SOUL then addCharges = 2
		elseif Pickup.SubType == HeartSubType.HEART_HALF_SOUL then addCharges = 1 end
		if type(addCharges) == 'nil' then return nil end
		
		if player:GetActiveItem(1) == Collectibles.STARGAZERSHAT and player:GetActiveItem(1) ~= Collectibles.STARGAZERSHAT then HatSlot = 1 end
		if player:GetActiveCharge(HatSlot) >= 4 then return nil end
		
		player:SetActiveCharge(player:GetActiveCharge(HatSlot) + addCharges, HatSlot)
		if player:GetActiveCharge(HatSlot) >= 4 then sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 2, false, 1, 0) else sfx:Play(SoundEffect.SOUND_BEEP, 1, 2, false, 1, 0) end
		Pickup:Remove()
		return false
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, rplus.PickupCollision)

						-- MC_POST_TEAR_UPDATE --
						-------------------------
function rplus:OnTearUpdate(Tear)
	if Tear.Variant == TearVariants.CEREMDAGGER then
		local TX = Tear.Velocity:Normalized().X
		local TY = Tear.Velocity:Normalized().Y
		
		if TY > 0 and TX <= TY and TX >= -TY then	-- down
			Tear:GetSprite().FlipY = true
		elseif TX > 0 and TY < TX and TY > -TX then		-- right
			Tear:GetSprite().Rotation = 90.0
		elseif TX <= 0 and TY < -TX and TY > TX then	-- left	
			Tear:GetSprite().Rotation = -90.0
		end
	end
	
	if Tear.Parent and Tear.Parent:ToPlayer() 
	and Tear.Parent:ToPlayer():HasCollectible(Collectibles.SINNERSHEART) and Tear.Variant ~= TearVariants.CEREMDAGGER then
		local SHeart = Tear:GetSprite()
			
		if Tear.FrameCount == 1 then
			SHeart.Scale = Vector(0.66, 0.66)
			SHeart:Load("gfx/002.121_sinners_heart_tear.anm2", true)
			SHeart:Play("MoveVert")
		end
		
		SHeart.Rotation = Tear.Velocity:GetAngleDegrees() - 90
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, rplus.OnTearUpdate)

						-- MC_POST_TEAR_INIT --											
						-----------------------
function rplus:OnTearInit(Tear)
	-- if Tear.Parent then local player = Tear.Parent:ToPlayer() end
	local player = Isaac.GetPlayer(0)
	
	if player:HasCollectible(Collectibles.CEREMDAGGER) and EntityRef(Tear).Entity.SpawnerType == EntityType.ENTITY_PLAYER then
		if math.random(100) <= CEREM_DAGGER_LAUNCH_CHANCE then
			-- launching the dagger
			local SBlade = Isaac.Spawn(2, TearVariants.CEREMDAGGER, 0, player.Position, Tear.Velocity, nil):GetSprite()
			SBlade:Load("gfx/002.120_ceremonial_blade_tear.anm2", true)
			SBlade:Play("Idle")
		end
	end
	
	if player:HasCollectible(Collectibles.SCALPEL) and EntityRef(Tear).Entity.SpawnerType == EntityType.ENTITY_PLAYER then 
		Tear.Velocity = -Tear.Velocity
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, rplus.OnTearInit)

						-- MC_PRE_TEAR_COLLISION --										
						---------------------------	
function rplus:TearCollision(Tear, Collider, _)				
	-- made specifically for antimaterial card, jeez
	if Collider:IsVulnerableEnemy() and not Collider:IsBoss() then
		table.insert(CustomData.Items.TEMPERTANTRUM.ErasedEnemies, Collider.Type)
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, rplus.TearCollision, TearVariants.ANTIMATERIALCARD)

						-- MC_EVALUATE_CACHE --							
						-----------------------
function rplus:UpdateStats(Player, Flag) 
	-- If any Stat-Changes are done, just check for the collectible in the cacheflag (be sure to set the cacheflag in the items.xml)
	if Flag == CacheFlag.CACHE_DAMAGE then
		if Player:HasCollectible(Collectibles.SINNERSHEART) then
			Player.Damage = Player.Damage + StatUps.SINNERSHEART_DMG_ADD
			Player.Damage = Player.Damage * StatUps.SINNERSHEART_DMG_MUL
		end
		
		if CustomData and CustomData.Items.MARKCAIN == "player revived" then
			Player.Damage = Player.Damage + #MyFamiliars * StatUps.MARKCAIN_DMG
		end
		
		if Player:HasCollectible(Collectibles.CEREMDAGGER) then
			Player.Damage = Player.Damage * StatUps.CEREMDAGGER_DMG_MUL
		end
		
		if CustomData and CustomData.Cards.SACBLOOD.Data then
			if Player:GetData()['usedBlood'] then
				Player.Damage = Player.Damage + StatUps.SACBLOOD_DMG * (CustomData.Cards.SACBLOOD.NumUses - Step / 50)
			end
		end
		
		if Player:HasTrinket(Trinkets.MAGICSWORD) then
			Player.Damage = Player.Damage * StatUps.MAGICSWORD_DMG_MUL * Player:GetTrinketMultiplier(Trinkets.MAGICSWORD)
		end
		
		if Player:HasTrinket(Trinkets.BONEMEAL) then
			Player.Damage = Player.Damage * StatUps.BONEMEAL_DMG_MUL ^ (CustomData.Trinkets.BONEMEAL.Levels * Player:GetTrinketMultiplier(Trinkets.BONEMEAL))
		end
		
		if CustomData and CustomData.Items.CHEESEGRATER.NumUses then
			if Player:GetData()['graterUsed'] == true then
				Player.Damage = Player.Damage + CustomData.Items.CHEESEGRATER.NumUses * StatUps.GRATER_DMG
			end
		end
		
		if Player:HasCollectible(Collectibles.BLESSOTDEAD) and CustomData then
			Player.Damage = Player.Damage + CustomData.Items.BLESSOTDEAD.NumUses * StatUps.BLESS_DMG
		end
		
		if CustomData then
			if Player:GetData()['GetYumDamage'] then
				Player.Damage = Player.Damage + CustomData.Pills.YUM.NumDamage * StatUps.YUM_DAMAGE
			end
		end
		
		if Player:HasCollectible(Collectibles.MOTHERSLOVE) then
			Player.Damage = Player.Damage + StatUps.MOTHERSLOVE_DMG * CustomData.Items.MOTHERSLOVE.NumStats
		end
		
		if CustomData and Player:GetData()['usedDemonForm'] then 
			Player.Damage = Player.Damage + CustomData.Cards.DEMONFORM.NumUses * StatUps.DEMONFORM_DAMAGE
		end
		
		if Player:GetData()['NumPickedBenightedHearts'] then
			Player.Damage = Player.Damage + Player:GetData()['NumPickedBenightedHearts'] * 0.1
		end
	end
	
	if Flag == CacheFlag.CACHE_FIREDELAY then
		if Player:HasCollectible(Collectibles.ORDLIFE) then
			Player.MaxFireDelay = Player.MaxFireDelay * StatUps.ORDLIFE_TEARS_MUL
		end
		
		if Player:HasCollectible(Collectibles.GUSTYBLOOD) then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + StatUps.GUSTYBLOOD_TEARS * CustomData.Items.GUSTYBLOOD.CurrentTears^2 / (CustomData.Items.GUSTYBLOOD.CurrentTears + 1))
		end
		
		if CustomData then
			if Player:GetData()['GetYumTears'] then
				Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomData.Pills.YUM.NumTears * StatUps.YUM_TEARS)
			end
		end
		
		if Player:HasCollectible(Collectibles.MOTHERSLOVE) then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + StatUps.MOTHERSLOVE_TEARS * CustomData.Items.MOTHERSLOVE.NumStats)
		end
	end
	
	if Flag == CacheFlag.CACHE_TEARFLAG then
		if Player:HasCollectible(Collectibles.SINNERSHEART) then
			Player.TearFlags = Player.TearFlags | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL
		end
		
		if Player:HasTrinket(Trinkets.TORNPAGE) and Player:GetData()['enhancedBoB'] then
			Player.TearFlags = Player.TearFlags | TearFlags.TEAR_BELIAL | TearFlags.TEAR_PIERCING
		end
	end
	
	if Flag == CacheFlag.CACHE_SHOTSPEED then
		if Player:HasCollectible(Collectibles.SINNERSHEART)  then
			Player.ShotSpeed = Player.ShotSpeed + StatUps.SINNERSHEART_SHSP
		end
	end
	
	if Flag == CacheFlag.CACHE_RANGE then 
		-- Range currently not functioning, blame Edmund
		-- it's working now, yo!
		if Player:HasCollectible(Collectibles.SINNERSHEART)  then
			Player.TearRange = Player.TearRange + StatUps.SINNERSHEART_RANGE * 40
		end
		
		if CustomData then
			if Player:GetData()['GetYumRange'] then
				Player.TearRange = Player.TearRange + CustomData.Pills.YUM.NumRange * StatUps.YUM_RANGE * 40
			end
		end
		
		if Player:HasCollectible(Collectibles.MOTHERSLOVE) then
			Player.TearRange = Player.TearRange + StatUps.MOTHERSLOVE_RANGE * CustomData.Items.MOTHERSLOVE.NumStats * 40
		end
	end
	
	if Flag == CacheFlag.CACHE_FAMILIARS then
		Player:CheckFamiliar(Familiars.BAGOTRASH, getTrueFamiliarNum(Player, Collectibles.BAGOTRASH), Player:GetCollectibleRNG(Collectibles.BAGOTRASH))
		Player:CheckFamiliar(Familiars.CHERUBIM, getTrueFamiliarNum(Player, Collectibles.CHERUBIM), Player:GetCollectibleRNG(Collectibles.CHERUBIM))
		Player:CheckFamiliar(Familiars.TOYTANK1, getTrueFamiliarNum(Player, Collectibles.TOYTANKS), Player:GetCollectibleRNG(Collectibles.TOYTANKS))
		Player:CheckFamiliar(Familiars.TOYTANK2, getTrueFamiliarNum(Player, Collectibles.TOYTANKS), Player:GetCollectibleRNG(Collectibles.TOYTANKS))
		Player:CheckFamiliar(Familiars.SIBLING1, getTrueFamiliarNum(Player, Collectibles.SIBLINGRIVALRY), Player:GetCollectibleRNG(Collectibles.SIBLINGRIVALRY))
		Player:CheckFamiliar(Familiars.SIBLING2, getTrueFamiliarNum(Player, Collectibles.SIBLINGRIVALRY), Player:GetCollectibleRNG(Collectibles.SIBLINGRIVALRY))
	end
	
	if Flag == CacheFlag.CACHE_LUCK then
		if Player:GetData()['usedLoadedDice'] then
			Player.Luck = Player.Luck + StatUps.LOADEDDICE_LUCK
		end
		
		if CustomData then
			if Player:GetData()['GetYumLuck'] then
				Player.Luck = Player.Luck + CustomData.Pills.YUM.NumLuck * StatUps.YUM_LUCK
			end
		end	
		
		if Player:HasCollectible(Collectibles.MOTHERSLOVE) then
			Player.Luck = Player.Luck + StatUps.MOTHERSLOVE_LUCK * CustomData.Items.MOTHERSLOVE.NumStats
		end
	end
	
	if Flag == CacheFlag.CACHE_SPEED then
		if Player:HasCollectible(Collectibles.GUSTYBLOOD) then
			Player.MoveSpeed = Player.MoveSpeed + StatUps.GUSTYBLOOD_SPEED * CustomData.Items.GUSTYBLOOD.CurrentSpeed^2 / (CustomData.Items.GUSTYBLOOD.CurrentSpeed + 1)
		end
		
		if Player:HasCollectible(Collectibles.MOTHERSLOVE) then
			Player.MoveSpeed = Player.MoveSpeed + StatUps.MOTHERSLOVE_SPEED * CustomData.Items.MOTHERSLOVE.NumStats
		end
		
		if Player:HasCollectible(Collectibles.NERVEPINCH) then
			Player.MoveSpeed = Player.MoveSpeed + StatUps.NERVEPINCH_SPEED * CustomData.Items.NERVEPINCH.NumTriggers
		end
	end
	
	if Flag == CacheFlag.CACHE_FLYING then
		if Player:GetData()['catchingBird'] then
			Player.CanFly = true
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, rplus.UpdateStats)

						-- MC_FAMILIAR_INIT --										
						----------------------
function rplus:FamiliarInit(Familiar)
	if Familiar.Variant == Familiars.BAGOTRASH then
		CustomData.Items.BAGOTRASH.Levels = 1
		Familiar:AddToFollowers()
		Familiar.IsFollower = true
		Familiar:GetSprite():Play("FloatDown")
	end
	
	if Familiar.Variant == Familiars.CHERUBIM then
	Familiar:AddToFollowers()
	Familiar.IsFollower = true
	Familiar:GetSprite():Play("FloatDown")
	end
	
	if Familiar.Variant == Familiars.TOYTANK1 or Familiar.Variant == Familiars.TOYTANK2 then 
		tankData = {
			[Familiars.TOYTANK1] = {lineOfSightDist = 450, lineOfSightAngle = 40, tankVelocityMul = 3.5, 
									tankAttackBuffer = 8, currBuffer = 0, projectileVelocityMul = 20, newRoomAttackHold = 0,
									newRoomCurrHold = 0},
			[Familiars.TOYTANK2] = {lineOfSightDist = 300, lineOfSightAngle = 10, tankVelocityMul = 1.75, 
									tankAttackBuffer = 90, currBuffer = 0, projectileVelocityMul = 10, newRoomAttackHold = 60,
									newRoomCurrHold = 0}
		}
		Familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		Familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	end
	
	if Familiar.Variant == Familiars.SIBLING1 or Familiar.Variant == Familiars.SIBLING2 or Familiar.Variant == Familiars.FIGHTINGSIBLINGS then
		Familiar:AddToOrbit(25)
		Familiar:GetSprite():Play("Idle")
	end
end
rplus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, rplus.FamiliarInit)

						-- MC_FAMILIAR_UPDATE --	 								
						------------------------
function rplus:FamiliarUpdate(Familiar)
	if Familiar.Variant == Familiars.BAGOTRASH then 
		Familiar:FollowParent()
		if Familiar:GetSprite():IsFinished("Spawn") then
			Familiar:GetSprite().PlaybackSpeed = 1.0
			Familiar:GetSprite():Play("FloatDown")
		end
		
		if Familiar.RoomClearCount == 1 then
			local NumFlies = math.random(math.ceil(CustomData.Items.BAGOTRASH.Levels * 1.5))
			
			Familiar:GetSprite().PlaybackSpeed = 0.5
			Familiar:GetSprite():Play("Spawn")
			for _ = 1, (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS, true) and NumFlies + math.random(2) or NumFlies) do 
				Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, 0, Familiar.Position, Vector.Zero, nil) 
			end
			Familiar.RoomClearCount = 0
		end
	end
	
	if Familiar.Variant == Familiars.CHERUBIM then
		Familiar:FollowParent()
		local Sprite = Familiar:GetSprite()
		
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			
			if player:HasCollectible(Collectibles.CHERUBIM) then
				if player:GetFireDirection() == Direction.NO_DIRECTION then
					Sprite:Play(DIRECTION_FLOAT_ANIM[player:GetMovementDirection()], false)
				else
					local TearVector = DIRECTION_VECTOR[player:GetFireDirection()]

					if Familiar.FireCooldown <= 0 then
						local Tear = Familiar:FireProjectile(TearVector):ToTear()
						Tear.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 10 or 5)
						Tear.TearFlags = TearFlags.TEAR_GLOW | TearFlags.TEAR_HOMING
						Tear:Update()

						if player:HasTrinket(Isaac.GetTrinketIdByName("Forgotten Lullaby")) then
							Familiar.FireCooldown = 11
						else
							Familiar.FireCooldown = 18
						end
					end

					Sprite:Play(DIRECTION_SHOOT_ANIM[player:GetFireDirection()], false)
				end

				Familiar.FireCooldown = Familiar.FireCooldown - 1
			end
		end
	end
	
	if Familiar.Variant == Familiars.SOUL then
		if CustomData.Items.ENRAGEDSOUL.AttachedEnemy then
			if CustomData.Items.ENRAGEDSOUL.AttachedEnemy:IsActiveEnemy() and AttachFrames >= 0 then
				Familiar.Position = CustomData.Items.ENRAGEDSOUL.AttachedEnemy.Position
				AttachFrames = AttachFrames - 1
			else 	
				Familiar:Kill()
				CustomData.Items.ENRAGEDSOUL.AttachedEnemy = nil
			end
		end
	end
	
	if Familiar.Variant == Familiars.TOYTANK1 or Familiar.Variant == Familiars.TOYTANK2 then 
		-- moving around (BASEMENT DRIFT YOOO)
		-- change direction naturally; they change direction when colliding with grid automatically
		if game:GetFrameCount() % 48 == 0 then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[math.random(#DIRECTION_VECTOR_SIMPLIFIED)] * tankData[Familiar.Variant].tankVelocityMul
		end
		-- correct the velocity when colliding with grid so that the tanks don't move diagonally
		local TX = Familiar.Velocity.X
		local TY = Familiar.Velocity.Y
		if TY > 0 and TX <= TY and TX >= -TY then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[1] * tankData[Familiar.Variant].tankVelocityMul
		elseif TX > 0 and TY < TX and TY > -TX then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[4] * tankData[Familiar.Variant].tankVelocityMul
		elseif TX <= 0 and TY < -TX and TY > TX then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[2] * tankData[Familiar.Variant].tankVelocityMul
		else
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[3] * tankData[Familiar.Variant].tankVelocityMul
		end
		
		local tankSprite = Familiar:GetSprite()
		if Familiar.Velocity.X < -0.1 and math.abs(Familiar.Velocity.Y) < 0.1  then tankSprite:Play("MoveLeft") 
		elseif Familiar.Velocity.Y < -0.1 and math.abs(Familiar.Velocity.X) < 0.1 then tankSprite:Play("MoveUp") 
		elseif Familiar.Velocity.X > 0.1 and math.abs(Familiar.Velocity.Y) < 0.1 then tankSprite:Play("MoveRight") 
		else tankSprite:Play("MoveDown") end
		
		-- shooting at enemies
		for _, enemy in pairs(Isaac.FindInRadius(Familiar.Position, tankData[Familiar.Variant].lineOfSightDist, EntityPartition.ENEMY)) do
			if enemy.Type ~= EntityType.ENTITY_SHOPKEEPER and enemy.Type ~= EntityType.ENTITY_FIREPLACE 
			and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_CHARM) then
				local curVel = Familiar.Velocity:Normalized()
				local posDiff = (enemy.Position - Familiar.Position):Normalized()
				
				if game:GetRoom():CheckLine(enemy.Position, Familiar.Position, 3, 0, false, false) and 
				math.abs(curVel:GetAngleDegrees() - posDiff:GetAngleDegrees()) < tankData[Familiar.Variant].lineOfSightAngle then
					if game:GetFrameCount() > tankData[Familiar.Variant].currBuffer + tankData[Familiar.Variant].tankAttackBuffer 
					and game:GetFrameCount() > tankData[Familiar.Variant].newRoomCurrHold + tankData[Familiar.Variant].newRoomAttackHold then
						if Familiar.Variant == Familiars.TOYTANK1 then
							local tankBullet = Isaac.Spawn(2, TearVariant.METALLIC, 0, Familiar.Position, posDiff * tankData[Familiar.Variant].projectileVelocityMul, nil):ToTear()
							tankBullet.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 7 or 3.5)
						elseif Familiar.Variant == Familiars.TOYTANK2 then
							local tankRocket = Isaac.Spawn(4, 19, 0, Familiar.Position, Vector.Zero, nil):ToBomb()
							tankRocket.SpriteScale = Vector(0.6, 0.6)
							tankRocket:GetData().forcedRocketTargetVel = curVel * tankData[Familiar.Variant].projectileVelocityMul
							tankRocket.ExplosionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 70 or 35)
						end
						tankData[Familiar.Variant].currBuffer = game:GetFrameCount()
					end
				end
			end
		end
	end
	
	if Familiar.Variant == Familiars.SIBLING1 or Familiar.Variant == Familiars.SIBLING2 or Familiar.Variant == Familiars.FIGHTINGSIBLINGS then
		Familiar.Velocity = Familiar:GetOrbitPosition(Familiar.Player.Position + Familiar.Player.Velocity) - Familiar.Position
	
		if Familiar.Variant == Familiars.SIBLING1 or Familiar.Variant == Familiars.SIBLING2 then
			Familiar.OrbitDistance = Vector(75, 75)
			Familiar.OrbitSpeed = 0.04
		else
			Familiar.OrbitDistance = Vector(60, 60)
			Familiar.OrbitSpeed = 0.03
			
			-- randomly shooting tooth tears and spawning blood creep
			if game:GetFrameCount() % 12 == 0 then
				local toothTear = Familiar:FireProjectile(Vector.FromAngle(math.random(360)))
				toothTear:ChangeVariant(TearVariant.TOOTH)
				toothTear.Velocity = toothTear.Velocity / 2
			end
			
			if game:GetFrameCount() % 18 == 0 then
				local creepPuddle = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, Familiar.Position, Vector.Zero, nil):ToEffect()
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, rplus.FamiliarUpdate)

						-- MC_POST_BOMB_UPDATE --									
						-------------------------
function rplus:BombUpdate(Bomb)
	if Bomb.SpawnerEntity and Bomb.SpawnerEntity:ToPlayer() then
		local player = Bomb.SpawnerEntity:ToPlayer()
		
		if player:HasCollectible(Collectibles.REDBOMBER) 
		and not Bomb:GetData()['isNewBomb'] 
		and not Bomb.IsFetus then
			if (Bomb.Variant == 0 or Bomb.Variant == 19) and Bomb.FrameCount == 1 then
				local throwableBomb = Isaac.Spawn(5, 41, 0, player.Position, Vector.Zero, nil)
				throwableBomb:GetSprite():Stop()
				bombFlags = Bomb.Flags
				Bomb:Remove()
			elseif Bomb.Variant == 13 and Bomb.FrameCount == 45 then
				--local newBomb = Isaac.Spawn(4, 0, 0, Bomb.Position, Bomb.Velocity, nil):ToBomb()
				local newBomb = player:FireBomb(Bomb.Position, Bomb.Velocity, nil)
				newBomb:AddTearFlags(bombFlags)
				newBomb:SetExplosionCountdown(1)
				newBomb:GetData()['isNewBomb'] = true
				Bomb:Remove()
			end		
		end
	end
	
	-- helper function for pointing toy tank's rockets in a right direction
	if Bomb.Variant == BombVariant.BOMB_ROCKET then
		if Bomb:GetData().forcedRocketTargetVel then
			Bomb.Velocity = Bomb:GetData().forcedRocketTargetVel
			Bomb.SpriteRotation = Bomb:GetData().forcedRocketTargetVel:GetAngleDegrees()
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, rplus.BombUpdate)

						-- MC_PRE_FAMILIAR_COLLISION --									
						-------------------------------
function rplus:FamiliarCollision(Familiar, Collider, _)
	if Familiar.Variant == Familiars.CHERRY then
		if Collider:IsActiveEnemy(true) and not Collider:IsBoss() and game:GetFrameCount() % 10 == 0 then
			game:CharmFart(Familiar.Position, 10.0, Familiar)
			sfx:Play(SoundEffect.SOUND_FART, 1, 2, false, 1, 0)
		end
	end	
	
	if Familiar.Variant == Familiars.BIRD then
		if Collider.Type == 1 then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				
				if player:GetData()['catchingBird'] then
					sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, 1, 0)
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, Familiar.Position, Vector.Zero, nil)
					Familiar:Remove()
					player.Position = DiePos
					player:TryRemoveNullCostume(Costumes.BIRDOFHOPE)
					CustomData.Items.BIRDOFHOPE.BirdCaught = true
					GiveRevivalIVFrames(player)
					player:GetData()['catchingBird'] = nil
					player:AddCacheFlags(CacheFlag.CACHE_FLYING)
					player:EvaluateItems()
				end
			end
		end
	end	
	
	if Familiar.Variant == Familiars.SOUL then	
		if Collider:IsActiveEnemy(true) and not Collider:HasEntityFlags(EntityFlag.FLAG_CHARM) and not CustomData.Items.ENRAGEDSOUL.AttachedEnemy then
			Familiar.Velocity = Vector.Zero
			CustomData.Items.ENRAGEDSOUL.AttachedEnemy = Collider
			AttachFrames = ENRAGED_SOUL_COOLDOWN / 2
			Familiar:GetSprite():Play("Idle", true)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, rplus.FamiliarCollision)

						-- MC_PRE_PROJECTILE_COLLISION --									
						---------------------------------
function rplus:ProjectileCollision(Projectile, Collider, _)
	if Collider.Variant == Familiars.BAGOTRASH then
		Projectile:Remove()
		
		if math.random(100) <= TRASHBAG_BREAK_CHANCE then
			sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 1, false, 1, 0)
			Isaac.GetPlayer(0):RemoveCollectible(Collectibles.BAGOTRASH)
			if math.random(100) <= 66 then
				Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_BREAKFAST, Collider.Position, Vector.Zero, nil)
			else
				Isaac.Spawn(5, 350, Trinkets.NIGHTSOIL, Collider.Position, Vector.Zero, nil)
			end
		end
	end
	
	if Collider.Variant == Familiars.SIBLING1 or
	Collider.Variant == Familiars.SIBLING2 or 
	Collider.Variant == Familiars.FIGHTINGSIBLINGS then
		Projectile:Remove()
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, rplus.ProjectileCollision)

						-- MC_PRE_PLAYER_COLLISION --										
						-----------------------------
function rplus:playerCollision(Player, Collider, _)
	if Player:HasTrinket(Trinkets.TRICKPENNY) and math.random(100) <= TRICKPENNY_CHANCE * Player:GetTrinketMultiplier(Trinkets.TRICKPENNY) then
		-- cuz slots don't have their own collision callback, thanks api lmao
		if Collider.Type == 6 then
			local S = Collider:GetSprite()
			
			-- make sure that we don't infinitely collide with them, results in infinite consumables!!!
			if S:GetFrame() == 1 and 
			(S:IsPlaying("PayPrize") or S:IsPlaying("PayNothing") or S:IsPlaying("PayShuffle") or S:IsPlaying("Initiate")) then
				if Player:GetNumCoins() > 0 and		-- slots that take your money
				(Collider.Variant == 1 or Collider.Variant == 3 or Collider.Variant == 4 or Collider.Variant == 6 or Collider.Variant == 10 or Collider.Variant == 13 or Collider.Variant == 18) then 
					Player:AddCoins(1)
				end
				if Player:GetNumBombs() > 0 and Collider.Variant == 9 then	-- that was bomb bum, simple stuff
					Player:AddBombs(1)
				end
				if Player:GetNumKeys() > 0 and Collider.Variant == 7 then	-- and that was a key master
					Player:AddKeys(1)
				end
			end
		elseif Collider.Type == 5 then
			local S = Collider:GetSprite()
			
			if S:GetFrame() == 1 and (S:IsPlaying("Open") or S:IsPlaying("UseKey")) and 	-- chests that require a key to open
			(Collider.Variant == 53 or Collider.Variant == 55 or Collider.Variant == 57 or Collider.Variant == 60) and	-- no golden keys or lockpicks allowed!
			not Player:HasGoldenKey() and not Player:HasTrinket(TrinketType.TRINKET_PAPER_CLIP) then 
				Player:AddKeys(1) 
			end
		end
	end
	
	if Player:HasCollectible(Collectibles.CEILINGSTARS) and Collider.Type == 5 and Collider.Variant == 380 and not CustomData.Items.CEILINGSTARS.SleptInBed then
		CustomData.Items.CEILINGSTARS.SleptInBed = true
		for i = 1, 2 do
			repeat 
				newID = GetUnlockedVanillaCollectible()
			until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
			Player:AddItemWisp(newID, Player.Position, true)
		end
	end
	
	if Collider.Type == 6 and Collider.Variant == PickUps.SLOT_STARGAZER and Player:GetNumCoins() >= 5 
	and Collider:GetSprite():IsPlaying("Idle") then
		Player:AddCoins(-5)
		Collider:GetSprite():Play("PayPrize")
		sfx:Play(SoundEffect.SOUND_SCAMPER, 1, 2, false, 1, 0)
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, rplus.playerCollision, 0)

						-- MC_PRE_SPAWN_CLEAN_AWARD --							
						------------------------------
function rplus:PickupAwardSpawn(_, Pos)
	local room = game:GetRoom()
	local level = game:GetLevel()
	
	--[[ Unlocking stuff
	if room:GetType() == RoomType.ROOM_BOSS and game.Difficulty <= 1 then
		if level:GetStage() == LevelStage.STAGE5 then
			if level:GetStageType() == StageType.STAGETYPE_ORIGINAL then
				Unlock("Satan")
			else
				Unlock("Isaac")
			end
		elseif level:GetStage() == LevelStage.STAGE6 and level:GetStageType() == StageType.STAGETYPE_WOTL then
			Unlock("Blue Baby")
		end
	elseif room:GetType() == RoomType.ROOM_BOSSRUSH then
		Unlock("Boss Rush")
	elseif isUltraGreedRoom() then
		Unlock("Greed")
	end
	--]]
	
	if CustomData and math.random(100) < JACK_CHANCE and CustomData.Cards.JACK and room:GetType() ~= RoomType.ROOM_BOSS then
		local Variant = nil
		local SubType = nil
		
		RNGobj:SetSeed(Random() + 1, 1)
		local DieRoll = RNGobj:RandomInt(100) + 1
		
		if CustomData.Cards.JACK == "Diamonds" then
			Variant = 20
			
			if DieRoll <= 80 then
				SubType = 1 --penny
			elseif DieRoll <= 95 then
				SubType = 2 --nickel 
			else
				SubType = 3 --dime
			end
		elseif CustomData.Cards.JACK == "Clubs" then
			Variant = 40
			
			if DieRoll <= 80 then
				SubType = 1 --bomb
			else
				SubType = 2	--double bomb
			end
		elseif CustomData.Cards.JACK == "Spades" then
			Variant = 30
			
			if DieRoll <= 80 then
				SubType = 1 --key
			elseif DieRoll <= 95 then
				SubType = 3	--double key
			else
				SubType = 4 --charged key
			end
		elseif CustomData.Cards.JACK == "Hearts" then
			Variant = 10
			
			if DieRoll <= 40 then
				SubType = 1 --Heart
			elseif DieRoll <= 60 then
				SubType = 2 --Half Heart
			elseif DieRoll <= 70 then
				SubType = 5 --Double Heart
			elseif DieRoll <= 85 then
				SubType = 3 --Soul Heart
			elseif DieRoll <= 93 then
				SubType = 10 --Blended Heart
			elseif DieRoll <= 98 then
				SubType = 6  --Black Heart
			else
				SubType = 4  --Eternal Heart
			end
		end
		
		Isaac.Spawn(5, Variant, SubType, game:GetRoom():FindFreePickupSpawnPosition(Pos, 0, true, false), Vector.Zero, nil)
		return true
	end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		for i = 1, CustomData.Hearts.SOILED do
			Isaac.Spawn(3, 201, -1, player.Position, Vector.FromAngle(math.random(360)) * 3, nil) --spawn dips for every half of soiled heart
		end
		if player:HasCollectible(Collectibles.REDKING) then
			if room:GetType() == RoomType.ROOM_BOSS 
			and level:GetStage() < 9 then
				if CustomData.Items.REDKING.IsInRedKingRoom then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_THERES_OPTIONS) then
						Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Vector(360, 360), Vector.Zero, nil):ToPickup().OptionsPickupIndex = 7
						Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Vector(280, 360), Vector.Zero, nil):ToPickup().OptionsPickupIndex = 7
					else
						Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Vector(320, 360), Vector.Zero, nil)
					end
					CustomData.Items.REDKING.DefeatedRedKingBoss = true
					return true
				else
					redTrapdoor = Isaac.Spawn(6, 334, 0, Vector(320, 280), Vector.Zero, nil)
					redTrapdoor:GetSprite():Play("OpenAnim")
				end
			end
		end
			
		if canOpenScarletChests(player)
		and math.random(100) <= SCARLETCHEST_REPLACE_CHANCE 
		and room:GetType() ~= RoomType.ROOM_BOSS then
			Isaac.Spawn(5, PickUps.SCARLETCHEST, 0, game:GetRoom():FindFreePickupSpawnPosition(Pos, 0, true, false), Vector.Zero, nil)
			sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			return true
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, rplus.PickupAwardSpawn)

						-- MC_GET_PILL_EFFECT --							
						------------------------
function rplus:ChangePillEffects(pillEffect, pillColor)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PHD) then
			if pillEffect == Pills.PHANTOM then
				return game:GetItemPool():GetPillEffect(1, player)
			end
		end
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
			if pillEffect == Pills.YUM or pillEffect == Pills.YUCK
			or pillEffect == Pills.ESTROGEN then
				return game:GetItemPool():GetPillEffect(1, player)
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_GET_PILL_EFFECT, rplus.ChangePillEffects)

						-- MC_POST_EFFECT_INIT --							
						-------------------------
function rplus:OnEffectInit(Effect)
	-- helper for killing stargazer beggars when the explosion is nearby
	if Effect.Variant == EffectVariant.BOMB_EXPLOSION or Effect.Variant == EffectVariant.MAMA_MEGA_EXPLOSION then
		for _, slot in pairs(Isaac.FindByType(6, PickUps.SLOT_STARGAZER, -1, false, true)) do
			if slot.Position:Distance(Effect.Position) <= 100 then
				slot:Kill()
				slot:Remove()
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, rplus.OnEffectInit)



								----------------------------------
								--- EXTERNAL ITEM DESCRIPTIONS ---
								----------------------------------
								
if EID then
	-- Enlish EID
	EID:addCollectible(Collectibles.ORDLIFE, "{{ArrowUp}} Tears up #Spawns an additional Mom/Dad related item in Treasure rooms alongside the presented items; only one item can be taken")	
	EID:addCollectible(Collectibles.COOKIECUTTER, "Gives you one {{Heart}} heart container and one broken heart #{{Warning}} Having 12 broken hearts kills you!")
	EID:addCollectible(Collectibles.SINNERSHEART, "+2 black hearts #{{ArrowUp}} Damage +2 then x1.5 #{{ArrowUp}} Grants +2 range and -0.2 shotspeed #Grants spectral and piercing tears")
	EID:addCollectible(Collectibles.RUBIKSCUBE, "After each use, has a 5% (100% on 20-th use) chance to be 'solved', removed from the player and be replaced with a Magic Cube item")
	EID:addCollectible(Collectibles.MAGICCUBE, "Rerolls item pedestals #Rerolled items can be drawn from any item pool")
	EID:addCollectible(Collectibles.MAGICPEN, "Double tap shooting button to spew a line of {{ColorRainbow}}rainbow{{CR}} creep in the direction you're firing #Random permanent status effects is applied to enemies walking over that creep #{{Warning}} Has a 4 seconds cooldown")
	EID:addCollectible(Collectibles.MARKCAIN, "On death, if you have any familiars, removes them instead and revives you #On revival, you keep your heart containers, gain +" .. tostring(StatUps.MARKCAIN_DMG) .. " DMG for each consumed familiar and gain invincibility #{{Warning}} Works only once!")
	EID:addCollectible(Collectibles.TEMPERTANTRUM, "25% chance to enter Berserk state when taking damage #While in this state, every enemy damaged has a 10% chance to be erased for the rest of the run")
	EID:addCollectible(Collectibles.BAGOTRASH, "A familiar that creates blue flies upon clearing a room #Blocks enemy projectiles, and after blocking it has a chance to be destroyed and drop Breakfast or Nightsoil trinket #The more floors it is not destroyed, the more flies it spawns")
	EID:addCollectible(Collectibles.CHERUBIM, "A familiar that rapidly shoots tears with Godhead aura")
	EID:addCollectible(Collectibles.CHERRYFRIENDS, "Killing an enemy has a 20% chance to drop cherry familiar on the ground #Those cherries emit a charming fart when an enemy walks over them, and drop half a heart when a room is cleared")
	EID:addCollectible(Collectibles.BLACKDOLL, "Upon entering a new room, all enemies will be split in pairs. Dealing damage to one enemy in each pair will deal 60% of that damage to another enemy in that pair")
	EID:addCollectible(Collectibles.BIRDOFHOPE, "Upon dying you turn into invincible ghost and a bird flies out of room center in a random direction. Catching the bird in 5 seconds will save you and get you back to your death spot, otherwise you will die #{{Warning}} Every time you die, the bird will fly faster and faster, making it harder to catch her")
	EID:addCollectible(Collectibles.ENRAGEDSOUL, "Double tap shooting button to launch a ghost familiar in the direction you are firing #The ghost will latch onto the first enemy it collides with, dealing damage over time for 7 seconds or until that enemy is killed #The ghost's damage per hit starts at 7 and increases each floor #The ghost can latch onto bosses aswell #{{Warning}} Has a 7 seconds cooldown")
	EID:addCollectible(Collectibles.CEREMDAGGER, "{{ArrowDown}} Damage x" .. tostring(StatUps.CEREMDAGGER_DMG_MUL) .. "#When shooting, 7% chance to launch a dagger that does no damage, but inflicts bleed on enemies #All enemies that die while bleeding will drop Sacrificial Blood Consumable that gives you temporary DMG up")
	EID:addCollectible(Collectibles.CEILINGSTARS, "Grants you two Lemegeton wisps at the beginning of each floor and when sleeping in bed")
	EID:addCollectible(Collectibles.QUASAR, "Consumes all item pedestals in the room and gives you 3 Lemegeton wisps for each item consumed")
	EID:addCollectible(Collectibles.TWOPLUSONE, "Every third shop item on the current floor will cost 1 {{Coin}} penny #Buying two items with hearts in one room makes all other items free")
	EID:addCollectible(Collectibles.REDMAP, "Reveals location of Ultra Secret Room on all subsequent floors #Any trinket left in a boss or treasure room will turn into Cracked Key, unless this is your first visit in such room")
	EID:addCollectible(Collectibles.CHEESEGRATER, "Removes one red heart container and gives you {{ArrowUp}} +" .. tostring(StatUps.GRATER_DMG) .. " Damage up and 3 Minisaacs")
	EID:addCollectible(Collectibles.DNAREDACTOR, "Pills now have additional effects based on their color")
	EID:addCollectible(Collectibles.TOWEROFBABEL, "Destroys all obstacles in the current room and applies confusion to enemies in small radius around you #Also blows the doors open and opens secret room entrances")
	EID:addCollectible(Collectibles.BLESSOTDEAD, "Prevents curses from appearing for the rest of the run #Preventing a curse grants you {{ArrowUp}} +" .. tostring(StatUps.BLESS_DMG) .. " Damage up")
	EID:addCollectible(Collectibles.TOYTANKS, "Spawns 2 Toy Tanks familiars that roam around the room and attack enemies that are in their line of sight #Green tank: rapidly shoots bullets at enemies from a further distance and moves more quickly #Red tank: shoots rockets at enemies at a close range, moves slower")
	EID:addCollectible(Collectibles.GUSTYBLOOD, "Killing enemies grants you {{ArrowUp}} tears and speed up #The bonus is reset when entering a new room")
	EID:addCollectible(Collectibles.REDBOMBER, "+5 bombs #Grants explosion immunity #Allows you to throw your bombs instead of placing them on the ground")
	EID:addCollectible(Collectibles.MOTHERSLOVE, "Grants you stat boosts for each familiar you own #Some familiars grant greater stat boosts, and some do not grant them at all (e.g. blue flies, dips or Isaac's body parts)")
	EID:addCollectible(Collectibles.CATINBOX, "When entering a room with enemies, their health is halved for the first 3 seconds, and then restored back to full #Doesn't work on bosses or minibosses")
	EID:addCollectible(Collectibles.BOOKOFGENESIS, "Removes a random item and spawns 3 items of the same quality #Only one item can be taken #Can't remove or spawn quest items")
	EID:addCollectible(Collectibles.SCALPEL, "Makes you shoot tears in the opposite direction #From the front, you will frequently shoot bloody tears that deal x0.66 of your damage #All other weapon types will still be fired from the front as well")
	EID:addCollectible(Collectibles.KEEPERSPENNY, "Spawns a golden penny upon entering a new floor #Shops will now sell 1-4 additional items that are drawn from shop, treasure or boss itempools #If the shop is a Greed fight, it instead spawns 3-4 items when the miniboss dies")
	EID:addCollectible(Collectibles.NERVEPINCH, "Shooting or moving for 8 seconds will trigger a nerve pinch #{{ArrowDown}} You take fake damage and gain a permanent " .. tostring(StatUps.NERVEPINCH_SPEED) .. " speed down when that happens #{{ArrowUp}} However, there is a 75% chance to activate your active item for free, even if it's uncharged #One-time use and infinite use actives cannot be used that way")
	EID:addCollectible(Collectibles.BLOODVESSELS[1], "Taking damage doesn't actually hurt the player, instead filling the blood vessel #This can be repeated 6 times until the vessel is full #Once it's full, using it or taking damage will empty it and deal 3 and 3.5 hearts of damage to the player, respectively")
	EID:addCollectible(Collectibles.SIBLINGRIVALRY, "Orbital that switches between 2 different states every 15 seconds: #Two orbitals that quickly rotate around Isaac #One orbital that rotates slower and closer to Isaac, and periodically shoots teeth in random directions and spawns blood creep underneath it #{{Warning}} All orbitals block enemy shots and do contact damage")
	EID:addCollectible(Collectibles.REDKING, "After defeating a boss, red crawlspace will appear in a middle of a room #Entering the crawlspace brings you to another bossfight of high difficulty #Victory rewards you a red item (from Ultra secret room pool)")
	EID:addCollectible(Collectibles.STARGAZERSHAT, "Summons the Stargazer beggar #Can only be charged with soul hearts, similar to Alabaster Box #2 soul hearts needed for full charge")
	EID:addCollectible(Collectibles.BOTTOMLESSBAG, "Upon use, holds the bag in the air #For 4 seconds, all nearby projectiles are sucked into the bag #After 4 seconds, all sucked projecties are released as homing tears in your firing direction")
	
	EID:addTrinket(Trinkets.BASEMENTKEY, "While held, every Golden Chest has a 5% chance to be replaced with Old Chest")
	EID:addTrinket(Trinkets.KEYTOTHEHEART, "While held, every enemy has a chance to drop Flesh Chest upon death #Flesh Chests contain 1-4 {{Heart}} heart/{{Pill}} pills or a random body-related item")
	EID:addTrinket(Trinkets.JUDASKISS, "Enemies touching you become targeted by other enemies (effect similar to Rotten Tomato)")
	EID:addTrinket(Trinkets.TRICKPENNY, "Using coin, bomb or key on slots, beggars or locked chests has a 17% chance to not subtract it from your inventory count")
	EID:addTrinket(Trinkets.SLEIGHTOFHAND, "Upon spawning, every coin has a 20% chance to be upgraded to a higher value: #penny -> doublepack pennies -> sticky nickel -> nickel -> dime -> lucky penny -> golden penny")
	EID:addTrinket(Trinkets.GREEDSHEART, "Gives you one empty coin heart #It is depleted before any of your normal hearts and can only be refilled by directly picking up money")
	EID:addTrinket(Trinkets.ANGELSCROWN, "All new treasure rooms will have an angel item for sale instead of a normal item #Angels spawned from statues will not drop Key Pieces!")
	EID:addTrinket(Trinkets.MAGICSWORD, "{{ArrowUp}} x2 DMG up while held #Breaks when you take damage #{{ArrowUp}} Having Duct Tape prevents it from breaking")
	EID:addTrinket(Trinkets.WAITNO, "Does nothing, it's broken")
	EID:addTrinket(Trinkets.EDENSLOCK, "Upon taking damage, one of your items rerolls into another random item #Doesn't take away nor give you story items")
	EID:addTrinket(Trinkets.CHALKPIECE, "When entering uncleared room, you will leave a trail of powder underneath for 5 seconds #Enemies walking over the powder will be pushed back")
	EID:addTrinket(Trinkets.ADAMSRIB, "Revives you as Eve when you die")
	EID:addTrinket(Trinkets.NIGHTSOIL, "75% chance to prevent a curse when entering a new floor")
	EID:addTrinket(Trinkets.BONEMEAL, "At the beginning of every new floor, grants:#{{ArrowUp}} +10% DMG up #{{ArrowUp}} Size increase #Both damage and size up stay if you drop the trinket")
	EID:addTrinket(Trinkets.TORNPAGE, "Amplifies or changes book's activation effects, or makes them charge faster #Apart from natural spawns, this trinket has a 33% chance to spawn in libraries")
	EID:addTrinket(Trinkets.EMPTYPAGE, "Books now activate a random active item on use #Doesn't work on How to Jump and doesn't proc dice and items that hurt or kill you #Apart from natural spawns, this trinket has a 33% chance to spawn in libraries")
	EID:addTrinket(Trinkets.BABYSHOES, "Reduces the size of all enemies by 20% #This affects both sprite and hitbox #Affects bosses too")
	
	EID:addCard(PocketItems.SDDSHARD, "Invokes the effect of Spindown Dice")
	EID:addCard(PocketItems.REDRUNE, "Damages all enemies in a room, turns item pedestals into red locusts and turns pickups into random locusts with a 50% chance")
	EID:addCard(PocketItems.NEEDLEANDTHREAD, "Removes one broken heart and grants one {{Heart}} heart container")
	EID:addCard(PocketItems.QUEENOFDIAMONDS, "Spawns  1-12 random {{Coin}} coins (those can be nickels or dimes as well)")
	EID:addCard(PocketItems.KINGOFSPADES, "Lose all your keys and spawn a number of pickups proportional to the of keys lost #At least 12 {{Key}} keys is needed for a trinket, and at least 28 for an item #If Isaac has {{GoldenKey}} Golden key, it is removed too and significantly increases total value")
	EID:addCard(PocketItems.KINGOFCLUBS, "Lose all your bombs and spawn a number of pickups proportional to the amount of bombs lost #At least 12 {{Bomb}} bombs is needed for a trinket, and at least 28 for an item #If Isaac has {{GoldenBomb}} Golden bomb, it is removed too and significantly increases total value")
	EID:addCard(PocketItems.KINGOFDIAMONDS, "Lose all your coins and spawn a number of pickups proportional to the amount of coins lost #At least 15 {{Coin}} coins is needed for a trinket, and at least 35 for an item")
	EID:addCard(PocketItems.BAGTISSUE, "All pickups in a room are destroyed, and 8 most valuables pickups form an item quality based on their total weight; the item of such quality is then spawned #The most valuable pickups are the rarest ones, e.g. {{EthernalHeart}} Eternal hearts or {{Battery}} Mega batteries #{{Warning}} If used in a room with less then 8 pickups, no item will spawn!")
	EID:addCard(PocketItems.RJOKER, "Teleports Isaac to a {{SuperSecretRoom}} Black Market")
	EID:addCard(PocketItems.REVERSECARD, "Invokes the effect of Glowing Hourglass")
	EID:addCard(PocketItems.LOADEDDICE, "{{ArrowUp}} Grants +10 Luck for the current room")
	EID:addCard(PocketItems.BEDSIDEQUEEN, "Spawns 1-12 random {{Key}} keys #There is a small chance to spawn a charged key")
	EID:addCard(PocketItems.QUEENOFCLUBS, "Spawns 1-12 random {{Bomb}} bombs #There is a small chance to spawn a double-pack bomb")
	EID:addCard(PocketItems.JACKOFCLUBS, "Bombs will drop more often after clearing rooms for the current floor, and the average quality of bombs is increased")
	EID:addCard(PocketItems.JACKOFDIAMONDS, "Coins will drop more often after clearing rooms the for current floor, and the average quality of coins is increased")
	EID:addCard(PocketItems.JACKOFSPADES, "Keys will drop more often after clearing rooms for the current floor, and the average quality of keys is increased")
	EID:addCard(PocketItems.JACKOFHEARTS, "Hearts will drop more often after clearing rooms for the current floor, and the average quality of hearts is increased")
	EID:addCard(PocketItems.QUASARSHARD, "Damages all enemies in a room and turns every item pedestal into 3 Lemegeton wisps")
	EID:addCard(PocketItems.BUSINESSCARD, "Summons a friendly monster, like ones from Friend Finder")
	EID:addCard(PocketItems.SACBLOOD, "{{ArrowUp}} Gives +1.25 DMG up that depletes over the span of 20 seconds #Stackable #{{ArrowUp}} Heals you for one red heart if you have Ceremonial Robes #{{Warning}} Damage depletes quicker the more Blood you used subsequently")
	EID:addCard(PocketItems.LIBRARYCARD, "Activates a random book effect")
	EID:addCard(PocketItems.FLYPAPER, "Grants 8 fly orbitals, similar to the Swarm item")
	EID:addCard(PocketItems.MOMSID , "Charms all enemies in the current room")
	EID:addCard(PocketItems.FUNERALSERVICES , "Spawns an Old Chest")
	EID:addCard(PocketItems.ANTIMATERIALCARD , "Can be thrown similarly to Chaos Card #If the card touches an enemy, that enemy is erased for the rest of the run")
	EID:addCard(PocketItems.FIENDFIRE, "Sacrifice your consumables for mass room destruction #7-40 total: enemies take 15 damage and burn for 4 seconds #41-80 total: the initital damage, the burning damage and burning duration are doubled; destroys obstacles around you #81+ total: the burning damage and burning duration are quadrupled; produces a Mama Mega explosion")
	EID:addCard(PocketItems.DEMONFORM, "{{ArrowUp}} Increases your damage by 0.15 for every new uncleared room you enter #The boost disappears when entering a new floor")
	
	EID:addPill(Pills.ESTROGEN, "Turns all your red health into blood clots #Leaves you at one red heart other types of hearts are unaffected")
	EID:addPill(Pills.LAXATIVE, "Makes you shoot out corn tears from behind for 3 seconds")
	EID:addPill(Pills.PHANTOM, "Makes Isaac take fake damage on pill use, then 15 and 30 seconds after")
	EID:addPill(Pills.YUCK, "Spawns a rotten heart #For 30 seconds, every red heart will spawn blue flies when picked up")
	EID:addPill(Pills.YUM, "Spawns a red heart #For 30 seconds, every red heart will grant you small permanent stat upgrades when picked up")
	
	--EID Spanish
	EID:addCollectible(Collectibles.ORDLIFE, "{{ArrowUp}} Tears up", "Vida Ordinaria", "spa")	
	EID:addCollectible(Collectibles.COOKIECUTTER, "Te otorga un {{Heart}} un contenedor de corazón y un corazón roto#{{Warning}} ¡Tener 12 corazones te matará!", "Cortador de Galletas", "spa")
	EID:addCollectible(Collectibles.SINNERSHEART, "{{ArrowUp}} +2 de daño, multiplicador de daño x1.5#{{ArrowDown}} baja la velocidad de tiro#lágrimas teledirigidas", "Corazón de los Pecadores", "spa")
	EID:addCollectible(Collectibles.RUBIKSCUBE, "Tras cada uso, hay un 5% (100% en el uso 20) de probabilidad de 'resolverlo', cuando esto ocurre, se le remueve al jugador y es reemplazado con un Cubo Mágico", "Cubo de Rubik", "spa")
	EID:addCollectible(Collectibles.MAGICCUBE, "{{DiceRoom}} Rerolea los pedestales de objetos #Los items reroleados se toman de cualquier pool", "Cubo Mágico", "spa")
	EID:addCollectible(Collectibles.MAGICPEN, "Las lágrimas dejan {{ColorRainbow}}{{CR}} creep arcoíris bajo ellas #Efectos de estado permantenes se aplican a los enemigos que caminen por el creep", "Pluma Mágica", "spa")
	EID:addCollectible(Collectibles.MARKCAIN, "Si mueres y tienes algún familiar, son eliminados a cambio de revivir #Al revivir, mantienes tus corazones, ganas +0.4 de daño por cada familiar sacrificado y ganas invencibilidad#{{Warning}}¡Sólo funciona una vez!", "La Marca de Cain", "spa")
	EID:addCollectible(Collectibles.TEMPERTANTRUM, "Al recibir daño, Hay un 25% de probabiliad de entrar al modo Berserk #Mientras el modo esté activo, Cada enemigo dañado tiene un 10% de ser eliminado de la partida", "Temper Tantrum", "spa")
	EID:addCollectible(Collectibles.BAGOTRASH, "Un familiar que genera moscas azules al limpiar una habitación #Puede bloquear disparos, al recibir un golpe tiene la posibilidad de romperse y otorgar {{Collectible25}}Desayuno o el trinket La Tierra de la Noch #Mientras más pisos pases sin romperlo, más moscas generará", "Bolsa de Basura", "spa")
	EID:addCollectible(Collectibles.CHERUBIM, "Un familiar que lanza lágrimas de {{Collectible331}} Cabeza de Dios a una cadencia de tiro alta", "Bebé Zen", "spa")
	EID:addCollectible(Collectibles.CHERRYFRIENDS, "Matar a un enemigo otorga un 20% de posibilidad de soltar un familiar cereza en el suelo #Estas cerezas emiten un pedo con efecto encantador cuando un enemigo camina sobre ellos, sueltan medio corazón al limpiar la habitación", "Amigos de Cereza", "spa")
	EID:addCollectible(Collectibles.BLACKDOLL, "Al entrar en una nueva habitación, Los enemigos serán divididos en pares. Dañar a un enemigo de un par, provocará la mitad del daño hecho en la otra mitad del par", "Muñeco Negro", "spa")
	EID:addCollectible(Collectibles.BIRDOFHOPE, "Al morir, revivirás como un fantasma invencible y un pájaro azul saldrá del centro de la habitación a una dirección aleatoria. Atrapar al pájaro en menos de 5 segundos te salvará y regreserás al punto donde moriste, de otra forma, morirás #{{Warning}} Cada vez que mueres, el pájaro volará con mayor velocidad, volviéndolo más difícil de atrapar", "Un Pájaro de la Esperanza", "spa")
	EID:addCollectible(Collectibles.ENRAGEDSOUL, "Presionar dos veces el botón de disparo hará que lances un fantasma en esa dirección#El fantasma se pegará con el primer enemigo con el que choque, dañándolo por 7 segundos o hasta que el enemigo muera #El fantasma también afecta a los jefes #{{Warning}}Tiene un cooldown de 7 segundos", "Alma Iracunda", "spa")
	EID:addCollectible(Collectibles.CEREMDAGGER, "{{ArrowDown}}Multiplicador de daño de x0.85 #Al disparar, hay un 7% de probabilidad de lanzar una daga que no hiere a los enemigos, pero los hace sangrar#Todo enemigo que muera desangrado soltará el consumible Sangre de Sacrificio, el cual otorgará un {{ArrowUp}}aumento de daño", "Daga Ceremonial", "spa")
	EID:addCollectible(Collectibles.CEILINGSTARS, "Otorga dos flamas de {{Collectible712}} Lemegeton por cada piso avanzado y cama a la que se va a dormir", "Móvil de estrellas", "spa")
	EID:addCollectible(Collectibles.QUASAR, "Consume todos los objetos en pedestal y otorga 3 flamas de {{Collectible712}}Lemegeton", "Quasar", "spa")
	EID:addCollectible(Collectibles.TWOPLUSONE, "Cada tercer objeto comprado en la tienda del piso actual costará 1 {{Coin}} penny #Comprar 2 objetos con corazones en una habitación hará que los demás se vuelvan gratuitos", "2+1", "spa")
	EID:addCollectible(Collectibles.REDMAP, "Revela la ubicación de la Sala Ultra Secreta en los siguientes pisos#Cualquier trinket que se deje en una {{TreasureRoom}}sala del tesoro o {{BossRoom}}sala del jefe dejará una Cracked Key", "Mapa Rojo", "spa")
	EID:addCollectible(Collectibles.CHEESEGRATER, "Remueve un contenedor de corazón rojo y otorga {{ArrowUp}} +0.5 de daño y 3 mini Isaacs", "Rayador de Queso", "spa")
	EID:addCollectible(Collectibles.DNAREDACTOR, "Ahora las píldoras reciben efectos adicionales en base a su color", "Redactor de ADN", "spa")
	EID:addCollectible(Collectibles.TOWEROFBABEL, "Destruye los obstáculos de la habitación y aplica confusión a los enemigos cercanos #Destroza las puertas y abre la entrada a Salas Secretas", "La Torre de Babel", "spa")
	EID:addCollectible(Collectibles.BLESSOTDEAD, "Previene las maldiciones durante toda la partida #Si se previene una maldición recibes {{ArrowUp}} +0.5 de daño", "Bendición de los muertos", "spa")
	EID:addCollectible(Collectibles.TOYTANKS, "Genera 2 tanques de juguete que rondan por la habitación y atacan a los enemigos dentro de su linea de visión #Tanque verde: Dispara balas rápidamente a los enemigos a gran distancia y es de movimiento rápido #Tanque rojo: Dispara cohetes a corto rango, de movimiento lento", "Tanquesitos", "spa")
	EID:addCollectible(Collectibles.GUSTYBLOOD, "Matar a los enemigos te da {{ArrowUp}} más lágrimas y velocidad #Se resetea al entrar a una nueva habitación", "Sangre Tempestuosa", "spa")
	EID:addCollectible(Collectibles.REDBOMBER, "+5 bombas #Ganas inmunidad a explosiones #Ahora puedes arrojar las bombas en vez de simplemente ponerlas en el suelo", "Bombardero Rojo", "spa")

	EID:addTrinket(Trinkets.BASEMENTKEY, "{{ChestRoom}} Al tenerlo, cada Cofre Dorado tiene un 5% de probabilidad de convertirse en un Cofre Viejo", "Llave del Sótano", "spa")
	EID:addTrinket(Trinkets.KEYTOTHEHEART, "Al tenerlo, cada enemigo tiene una posibilidad de soltar un Cofre Escarlata al morir#Los Cofres Escarlata contienen: 1-4 {{Heart}} corazones/{{Pill}} píldoras O un objeto aleatorio relativo al cuerpo", "Llave al Corazón", "spa")
	EID:addTrinket(Trinkets.JUDASKISS, "Los enemigos que te toquen serán marcados y atacados por otros enemigos (Efecto similar al de {{Collectible618}} Tomate Podrido", "Beso de Judas", "spa")
	EID:addTrinket(Trinkets.TRICKPENNY, "Usar una moneda, llave o bomba en una máquina, un mendigo o un cofre cerrado tendrá un 17% de probabilidad de no restarlo de tu ivnentario", "Moneda Truculenta", "spa")
	EID:addTrinket(Trinkets.SLEIGHTOFHAND, "Al momento de generarse, cada moneda tiene un 20% de posibilidad de recibir una mejora: #penny -> penny doble -> nickel pegajoso -> nickel -> décimo -> penny de la suerte -> penny dorado", "Juego de Manos", "spa")
	EID:addTrinket(Trinkets.GREEDSHEART, "Te otorga una Moneda corazón vacía #Esta se vacía antes que tus corazones regulares, se rellena consiguiendo dinero", "Corazón de la Codicia", "spa")
	EID:addTrinket(Trinkets.ANGELSCROWN, "Toda nueva sala del ángel tendrá un objeto de la pool del ángel a la venta en vez de un objeto de la pool del tesoro#Los ángeles de las estatuas no generarán {{Collectible238}}{{Collectible239}}Piezas de Llave", "Corona de Ángel", "spa")
	EID:addTrinket(Trinkets.MAGICSWORD, "{{ArrowUp}} x2 de daño al sostenerlo#Se rompe al recibir daño#{{ArrowUp}}Tener Cinta Adhesiva evitará que se rompa", "Espada Mágica", "spa")
	EID:addTrinket(Trinkets.WAITNO, "No hace nada, está rota", "Espera... ¡NO!", "spa")
	EID:addTrinket(Trinkets.EDENSLOCK, "Al recibir daño, uno de tus objetos será reroleado a otro objeto aleatorio #No quita ni otorga objetos relativos a la historia", "Mechón de Eden", "spa")
	EID:addTrinket(Trinkets.CHALKPIECE, "Al entrar a una sala nueva, dejarás un rastro de talco bajo tuyo durante 5 segundos#Los enemigos que intenten caminar por el rastro serán repelidos", "Pedazo de Tiza", "spa")
	EID:addTrinket(Trinkets.ADAMSRIB, "Revives como Eve al morir", "Costilla de Adan", "spa")
	EID:addTrinket(Trinkets.NIGHTSOIL, "75% de posibilidad de prevenir una maldición al pasar a un nuevo piso", "La Tierra de la Noche", "spa")
	
	EID:addCard(PocketItems.SDDSHARD, "Efecto de {{Collectible723}} Spindown Dice de un solo uso", "Fragmento de Spindown Dice", "spa")
	EID:addCard(PocketItems.REDRUNE, "Daña a todos los enemigos de una habitación, los objetos en pedestales se convierten en langostas rojas y los consumibles tienen 50% de probabilidad de convertirse en una langosta roja", "Runa Roja", "spa")
	EID:addCard(PocketItems.NEEDLEANDTHREAD, "Remueve un Corazón Roto y otorga un {{Heart}} Contenedor de Corazón", "Aguja e Hilo", "spa")
	EID:addCard(PocketItems.QUEENOFDIAMONDS, "Genera 1-12 {{Coin}} monedas aleatorias (pueden ser tanto nickels como décimos)", "Reina de Diamantes", "spa")
	EID:addCard(PocketItems.KINGOFSPADES, "Pierdes todas tus llaves y se genera un número proporcional a la cantidad perdida en recolectables #Se necesitan al menos 12 {{Key}} llaves para generar un trinket y al menos 28 para un objeto#Si Isaac tiene una {{GoldenKey}} Llave Dorada, Será removida y aumentará el valor de la recompensa significativamente", "Rey de Espadas", "spa")
	EID:addCard(PocketItems.KINGOFCLUBS, "Pierdes todas tus bombas y se genera un número proporcional a la cantidad perdida en recolectables#Se necesitan al menos 12 {{Bomb}} bombas para generar un trinket y al menos 28 para un objeto#Si Isaac tiene una {{GoldenBomb}} Bomba Dorada, Será removida y aumentará el valor de la recompensa significativamente", "Rey de Tréboles", "spa")
	EID:addCard(PocketItems.KINGOFDIAMONDS, "Pierdes todas tus monedas y se genera un número proporcional a la cantidad perdida en recolectables#Se necesitan al menos 12 {{Coin}} monedas para generar un trinket y al menos 28 para un objeto", "Rey de Diamantes", "spa")
	EID:addCard(PocketItems.BAGTISSUE, "Destruye todos los recolectables, y los ocho recolectables de mayor valor generarán un objeto con una calidad basada en el valor de los recolectables#Los recolectables con mayor valor son los más raros, por ejemplo:{{EthernalHeart}} Corazones Eternos o {{Battery}} Mega Baterías#{{Warning}} Si se usa en una habitación sin recolectables, no generará nada", "Bolsa de tela", "spa")
	EID:addCard(PocketItems.RJOKER, "Teletransporta a Isaac a un {{SuperSecretRoom}} Mercado Negro", "bufón?", "spa")
	EID:addCard(PocketItems.REVERSECARD, "Activa el efecto de {{Collectible422}} Reloj de arena brillante", "¿Comodín?", "spa")
	EID:addCard(PocketItems.LOADEDDICE, "{{ArrowUp}} +10 de suerte durante una habitación", "dado cargado", "spa")
	EID:addCard(PocketItems.BEDSIDEQUEEN, "Genera 1-12 {{Key}} llaves#Hay una posibilidad de generar una Llave Cargada", "Reina de Espadas", "spa")
	EID:addCard(PocketItems.QUEENOFCLUBS, "Genera 1-12 {{Bomb}} bombas#Hay una posibilidad de generar una bomba doble", "Reina de Tréboles", "spa")
	EID:addCard(PocketItems.JACKOFCLUBS, "Se generarán más bombas al limpiar habitaciones, la calidad general de las bombas aumenta", "Jota de Tréboles", "spa")
	EID:addCard(PocketItems.JACKOFDIAMONDS, "Se generarán más monedas al limpiar habitaciones, la calidad general de las monedas aumenta", "Jota de Diamantes", "spa")
	EID:addCard(PocketItems.JACKOFSPADES, "Se generarán más llaves al limpiar habitaciones, la calidad general de las llaves aumenta", "Jota de Espadas", "spa")
	EID:addCard(PocketItems.JACKOFHEARTS, "Se generarán más corazones al limpiar habitaciones, la calidad general de los corazones aumenta", "Jota de Corazones", "spa")
	EID:addCard(PocketItems.QUASARSHARD, "Dañaa todos los enemigos de la habitación, convierte cada pedestal de objeto en 3 flamas de {{Collectible712}} Lemegeton", "Fragmento de Quasar", "spa")
	EID:addCard(PocketItems.BUSINESSCARD, "Invoca un enemigo aliado aleatorio, al igual que {{Collectible687}} Buscador de Amigos", "Carta de Negocios", "spa")
	EID:addCard(PocketItems.SACBLOOD, "{{ArrowUp}} +1.25 de daño que decrementa tras 20 segundos#Acumulable#{{ArrowUp}} Cura un corazón rojo si tienes {{Collectible216}} Batas Ceremoniales#{{Warning}} El daño disminuirá más rápido mientras más sangre uses", "Sangre de Sacrificio", "spa")
	EID:addCard(PocketItems.LIBRARYCARD, "Activa un efecto aleatorio de un Libro", "Carta de Biblioteca", "spa")
	EID:addCard(PocketItems.FLYPAPER, "Genera 8 moscas de {{Collectible693}} El Enjambre", "Trampa para Moscas", "spa")
	
	EID:addPill(Pills.ESTROGEN, "Convierte todos tus {{Heart}}corazones en Coágulos#Te deja con al menos un corazón rojo, No afecta Corazones de Alma/Corazones Negros", "Estrógeno", "spa")
	EID:addPill(Pills.LAXATIVE, "Hace que dispares los maíces de {{Collectible680}}Venganza de Montezuma durante 3 segundos", "Laxante", "spa")
	EID:addPill(Pills.PHANTOM, "Provoca que Isaac reciba daño falso al usarse, luego a los 15 y 30 segundos de haberla consumido", "Fantasma", "spa")
	EID:addPill(Pills.YUCK, "Genera un corazón podrido #Por 30 segundos, cada corazón rojo tomado generará moscas azules", "Puaj", "spa")
	EID:addPill(Pills.YUM, "Genera un corazón rojo #Por, cada corazón rojo que consigas te dará un pequeño aumento permantente de estadísticas, Igual al efecto de {{Collectible671}} Corazón de Caramelo", "Mmm~", "spa")

	-- EID Russian
	EID:addCollectible(Collectibles.ORDLIFE, "{{ArrowUp}} Повышает скорострельность #Создает дополнительный предмет, связанный с матерью/отцом, в сокровищницах; можно взять только один предмет", "Обычная Жизнь", "ru")	
	EID:addCollectible(Collectibles.COOKIECUTTER, "При использовании дает один {{Heart}} контейнер сердца и одно сломанное сердце #{{Warning}} При 12 сломанных сердец вы умрете!", "Формочка для Печенья", "ru")
	EID:addCollectible(Collectibles.SINNERSHEART, "+2 черных сердца #{{ArrowUp}} Дает +2 к урону и умножает на 1.5 #{{ArrowUp}} Дает +2 к дальности и -0.2 к скорости слезы #Дает спектральные и пронзающие слезы", "Сердце Грешника", "ru")
	EID:addCollectible(Collectibles.RUBIKSCUBE, "После каждого использования, имеет 5%(100% на 20-ом использовании) шанс стать 'собранным', забирает у игрока этот предмет и заменяет его Магическим Кубом", "Кубик Рубика", "ru")
	EID:addCollectible(Collectibles.MAGICCUBE, "{{DiceRoom}} Меняет предметы в комнате #Замененные предметы могут быть из любого пула предметов", "Магический Куб", "ru")
	EID:addCollectible(Collectibles.MAGICPEN, "При двойном нажатие кнопки стрельбы создает на полу полосу {{ColorRainbow}}радужной{{CR}} лужи в направлении стрельбы #Лужа накладывает случайные статусные эффекты врагам при соприкосновении#{{Warning}} Имеет 4 секунды перезарядки", "Магическая Ручка", "ru")
	EID:addCollectible(Collectibles.MARKCAIN, "При смерти, если у вас есть спутники, убирает их и воскрешает вас #При воскрешении вы оставляете все ваши контейнеры сердец, и получаете +" .. tostring(StatUps.MARKCAIN_DMG) .. "к урону за каждого потерянного спутника #{{Warning}} Работает только один раз!", "Метка Каина", "ru")
	EID:addCollectible(Collectibles.TEMPERTANTRUM, "При получении урона, есть 25% шанс войти в режим Берсерка #В этом состоянии, любой пораженный враг имеет 10% шанс стать стертым до конца забега", "Приступ Ярости", "ru")
	EID:addCollectible(Collectibles.BAGOTRASH, "Спутник призывающий мух при зачистке комнат #Блокирует вражеские выстрелы, при блокировании имеет небольшой шанс быть уничтоженным и создать предмет Завтрак или брелок Ночное Золото #Чем больше этажей этот спутник выживает, тем больше мух он призывает", "Мешок для Мусора", "ru")
	EID:addCollectible(Collectibles.CHERUBIM, "Спутник, быстро стреляющий слезами с аурой {{Collectible331}} Головы Бога", "Херувим", "ru")
	EID:addCollectible(Collectibles.CHERRYFRIENDS, "При убийстве врага есть 20% шанс призвать на его месте спутника вишенку #Вишенки испускают очаровывающий пук при соприкосновении с врагами, и создает половинку красного сердца после зачистки комнаты", "Вишенки", "ru")
	EID:addCollectible(Collectibles.BLACKDOLL, "При посещении комнаты, все враги будут разделены на пары. Нанося урон врагу, также наносит половину урона другому врагу в этой паре", "Черная Кукла", "ru")
	EID:addCollectible(Collectibles.BIRDOFHOPE, "При смерти персонаж превращается в неуязвимого призрака, и птица вылетает из центра комнаты в случайном направление. При поимке птицы вы воскрешаетесь и возвращаетесь на место своей смерти, если вы не успеваете поймать птицу вы умираете. Ужасной смертью #{{Warning}} За каждую вашу смерть, птица становится быстрее, затрудняя ее поймать", "Птичка Надежды", "ru")
	EID:addCollectible(Collectibles.ENRAGEDSOUL, "При двойном нажатии кнопки стрельбы запускает призрака в направление стрельбы #Призрак прилипнет ко врагу нанося урон на протяжении 7 секунд или до тех пор пока этот враг умрет#Призрак наносит 7 урона и повышается каждый этаж #Также Призрак может прилипать к боссам #{{Warning}} Призрак имеет 7 секунд перезарядки", "Разъяренная Душа", "ru")
	EID:addCollectible(Collectibles.CEREMDAGGER, "{{ArrowDown}} Урон x" .. tostring(StatUps.CEREMDAGGER_DMG_MUL) .. "#При стрельбе есть 7%  шанс запустить кинжал, который не наносит урона, но накладывает кровотечение на врагов #Враги которые умерли пока кровоточили оставят за собой Жертвенную Кровь, которая дает временную прибавку к урону", "Церемониальный Кинжал", "ru")
	EID:addCollectible(Collectibles.CEILINGSTARS, "Дает 2 огонька {{Collectible712}} Лемегетона в начале каждого этажа и когда вы спите в кровати ", "Потолок со Звездами", "ru")
	EID:addCollectible(Collectibles.QUASAR, "Поглощает все предметы на пьедесталах в комнате и дает 3 огонька {{Collectible712}} Лемегетона за каждый поглощенный предмет", "Квазар", "ru")
	EID:addCollectible(Collectibles.TWOPLUSONE, "Каждый третий купленный предмет будет стоить 1 {{Coin}} пенни #Покупка двух предметов сердцами сделает все остальные предметы бесплатными", "2+1", "ru")
	EID:addCollectible(Collectibles.REDMAP, "Показывает местоположение Ультра Секретной Комнаты на последующих этажах #Любой брелок оставленный в комнате босса или сокровищнице превратиться в Треснутый Ключ", "Красная Карта", "ru")
	EID:addCollectible(Collectibles.CHEESEGRATER, "Забирает один контейнер сердца и дает {{ArrowUp}} +0.5 к урону и создает 3 мини Айзека", "Терка для Сыра", "ru")
	EID:addCollectible(Collectibles.DNAREDACTOR, "Пилюли дают дополнительный эффект в зависимости от их цвета", "Редактор ДНК", "ru")
	EID:addCollectible(Collectibles.TOWEROFBABEL, "Уничтожает все препятствия в этой комнате и накладывает на врагов в маленьком радиусе замешательство #Также подрывает двери и проход в секретную комнату", "Вавилонская Башня", "ru")
	EID:addCollectible(Collectibles.BLESSOTDEAD, "Предотвращает проклятья до конца забега #Предотвращение проклятья дает вас {{ArrowUp}} +" .. tostring(StatUps.BLESS_DMG) .. "к урону", "Благословение Мертвых", "ru")
	EID:addCollectible(Collectibles.TOYTANKS, "Призывает двух спутников Танкистов, которые катаются по комнате и атакуют врагов находящиеся в их поле зрения #Зеленый танк: быстро стреляет по врагам на далекой дистанции и двигается быстро #Красный танк: стреляет ракетами по врагам на маленькой дистанции и двигается медленно", "Танкисты", "ru")
	EID:addCollectible(Collectibles.GUSTYBLOOD, "Убийство врагов дает {{ArrowUp}} повышении к скорострельности и к скорости #Бонус пропадает при выходе из комнаты", "Бурная Кровь", "ru")
	EID:addCollectible(Collectibles.REDBOMBER, "+5 бомб #Дает иммунитет к взрывам #Позволяет вам бросать бомбы", "Красный Бомбардировщик", "ru")
	EID:addCollectible(Collectibles.MOTHERSLOVE, "Дает повышение к случайной характеристике за каждого спутника", "Мамина Любовь", "ru")
	EID:addCollectible(Collectibles.CATINBOX, "При входе в комнату с врагами их здоровье уменьшается вдвое в течение первых 3 секунд, а затем восстанавливается до полного #Не работает с боссами или минибоссами", "Кот в Коробке", "ru")
	EID:addCollectible(Collectibles.BOOKOFGENESIS, "Удаляет ваш случайный предмет и создает три предмета того же качества #Только один предмет можно взять", "Книга Бытия", "ru")

	EID:addTrinket(Trinkets.BASEMENTKEY, "{{ChestRoom}} Золотые Сундуки имеют 5% шанс стать Старым Сундуком", "Ключ от Подвала", "ru")
	EID:addTrinket(Trinkets.KEYTOTHEHEART, "У каждого врага есть шанс создать Алый Сундук после смерти #Алые Сундуки могут содержать 1-4 {{Heart}} сердца/{{Pill}} таблетки или случайный предмет, связанный с телом", "Ключ к Сердцу", "ru")
	EID:addTrinket(Trinkets.JUDASKISS, "Враги, прикасающиеся к вам, будут атакованы другими врагами (похожий на эффект {{Collectible618}} Тухлого Помидора)", "Поцелуй Иуды", "ru")
	EID:addTrinket(Trinkets.TRICKPENNY, "Трата монет, бомб или ключей на автоматы, попрошаек или запертые сундуки имеет 17 % шанс не вычесть их из вашего инвентаря", "Трюк с Монеткой", "ru")
	EID:addTrinket(Trinkets.SLEIGHTOFHAND, "После появления каждая монета имеет 20% шанс быть повышена до более высокой стоимости: #пенни->двойной пенни->липкий никель->никель-> десятник->счастливый пенни->золотой пенни", "Ловкость Рук", "ru")
	EID:addTrinket(Trinkets.GREEDSHEART, "Дает вам один пустой контейнер монет #Оно тратится раньше, чем обычные сердца, и может быть пополнено только путем прямого подбирания монеток", "Сердце Жадности", "ru")
	EID:addTrinket(Trinkets.ANGELSCROWN, "Во всех новых Сокровищницах будет продаваться предмет ангела вместо обычного предмета #Ангелы не оставят части ключа при битве!", "Ангельская Корона", "ru")
	EID:addTrinket(Trinkets.MAGICSWORD, "{{ArrowUp}} Удваивает ваш урон #Ломается, когда вы получаете урон #{{ArrowUp}} Наличие Клейкой Ленты предотвращает поломку", "Магический Меч", "ru")
	EID:addTrinket(Trinkets.WAITNO, "Ничего не делает", "О Нет!", "ru")
	EID:addTrinket(Trinkets.EDENSLOCK, "При получении урона один из ваших предметов меняется на другой случайный предмет", "Локон Эдема", "ru")
	EID:addTrinket(Trinkets.CHALKPIECE, "При входе в комнату вы оставляете под собой след из порошка в течение 5 секунд #Враги, проходящие по порошку, будут отброшены назад", "Кусок Мела", "ru")
	EID:addTrinket(Trinkets.ADAMSRIB, "При смерти, воскрешает вас за Еву", "Ребро Адама", "ru")
	EID:addTrinket(Trinkets.NIGHTSOIL, "75% шанс предотвратить проклятия при входе на новый этаж", "Ночное Золото", "ru")
	
	EID:addCard(PocketItems.SDDSHARD, "Активирует эффект {{Collectible723}} Кубика с Вычетом", "Осколок Кубика с Вычетом", "ru")
	EID:addCard(PocketItems.REDRUNE, "Наносит урон всем врагам в комнате, превращает все пьедесталы с предметами в красную саранчу и превращает пикапы в случайную саранчу с вероятностью 50%", "Красная Руна", "ru")
	EID:addCard(PocketItems.NEEDLEANDTHREAD, "Убирает одно Сломанное Сердце и дает один {{Heart}} Контейнер Сердца", "Игла и Нитка", "ru")
	EID:addCard(PocketItems.QUEENOFDIAMONDS, "Создает 1-12 {{Coin}} случайных монет", "Дама Бубен", "ru")
	EID:addCard(PocketItems.KINGOFSPADES, "Вы теряете все свои ключи и создаете количество пикапов, пропорциональное количеству потерянных ключей #Для брелка требуется не менее 12 {{Key}} ключей и не менее 28 для предмета #Если у вас есть {{GoldenKey}} Золотой Ключ, он тоже удаляется и значительно увеличивает количество пикапов", "Король Пик", "ru")
	EID:addCard(PocketItems.KINGOFCLUBS, "Вы теряете все свои бомбы и создаете количество пикапов, пропорциональное количеству потерянных бомб #Для брелка требуется не менее 12 {{Bomb}} бомб и не менее 28 для предмета #Если у вас есть {{GoldenBomb}} Золотая Бомба, он тоже удаляется и значительно увеличивает количество пикапов", "Король Треф", "ru")
	EID:addCard(PocketItems.KINGOFDIAMONDS, "Вы теряете все свои монеты и создаете количество пикапов, пропорциональное количеству потерянных монет #Для брелка требуется не менее 12 {{Coin}} монет и не менее 28 для предмета", "Король Бубен", "ru")
	EID:addCard(PocketItems.BAGTISSUE, "Все пикапы в комнате уничтожаются, и 8 самых ценных пикапов формируют качество предмета на основе их общей ценности; затем появляется предмет такого качества #Самые ценные пикапы - самые редкие, например {{EternalHeart}} Вечные сердца или {{Battery}} Мега Батареи #{{Warning}} При использовании в комнате с менее чем 8 пикапами предмет не появится!", "Ткань", "ru")
	EID:addCard(PocketItems.RJOKER, "Телепортирует вас в {{SuperSecretRoom}} Черный Рынок", "Джокер?", "ru")
	EID:addCard(PocketItems.REVERSECARD, "Активирует эффект {{Collectible422}} Светящихся Песочных Часов", "Обратная Карта", "ru")
	EID:addCard(PocketItems.LOADEDDICE, "{{ArrowUp}} +10 к удаче на одну комнату", "Шулерские Кости", "ru")
	EID:addCard(PocketItems.BEDSIDEQUEEN, "Создает 1-12 {{Key}} случайных ключей", "Дама Пик", "ru")
	EID:addCard(PocketItems.QUEENOFCLUBS, "Создает 1-12 {{Bomb}} случайных бомб", "Дама Треф", "ru")
	EID:addCard(PocketItems.JACKOFCLUBS, "Бомбы будут чаще падать после прохождение комнат на этом этажа, и качество бомб увеличится", "Валет Треф", "ru")
	EID:addCard(PocketItems.JACKOFDIAMONDS, "Монеты будут чаще падать после прохождение комнат на этом этажа, и качество монет увеличится", "Валет Бубен", "ru")
	EID:addCard(PocketItems.JACKOFSPADES, "Ключи будут чаще падать после прохождение комнат на этом этажа, и качество ключей увеличится", "Валет Пик", "ru")
	EID:addCard(PocketItems.JACKOFHEARTS, "Сердца будут чаще падать после прохождение комнат на этом этажа, и качество сердец увеличится", "Валет Червей", "ru")
	EID:addCard(PocketItems.QUASARSHARD, "Поглощает все предметы на пьедесталах в комнате и дает 3 огонька {{Collectible712}} Лемегетона за каждый поглощенный предмет", "Осколок Квазара", "ru")
	EID:addCard(PocketItems.BUSINESSCARD, "Активирует эффект {{Collectible687}} Искателя Друзей", "Визитная Карточка", "ru")
	EID:addCard(PocketItems.SACBLOOD, "{{ArrowUp}} Дает +1,25 урона, который истощается в течение 20 секунд #{{ArrowUp}} Исцеляет вас на одно Красное Сердце, если у вас есть Церемониальные Роба #{{Warning}} Чем больше крови вы использовали впоследствии, тем быстрее понижается урон", "Жертвенная Кровь", "ru")
	EID:addCard(PocketItems.LIBRARYCARD, "Активирует эффект случайной книги", "Читательский Билет", "ru")
	EID:addCard(PocketItems.FLYPAPER, "Создает 8 мух схожие с предметом {{Collectible693}} Рой", "Липучка", "ru")
	EID:addCard(PocketItems.MOMSID , "Очаровывает всех врагов в комнате", "Мамино Удостоверение", "ru")
	EID:addCard(PocketItems.FUNERALSERVICES , "Создает Старый Сундук", "Похоронное Бюро", "ru")
	EID:addCard(PocketItems.ANTIMATERIALCARD , "Можно кинуть как Карту Хаоса #При попадании стирает врага до конца забега", "Антиматериальная Карта", "ru")

	EID:addPill(Pills.ESTROGEN, "Превращает все ваши {{Heart}} сердца в блебиков #Оставляет вас по крайней мере с одним красным сердцем, не убирает сердца души/черные сердца", "Эстроген", "ru")
	EID:addPill(Pills.LAXATIVE, "Заставляет вас стрелять кукурузой сзади в течение 3 секунд", "Слабительное", "ru")
	EID:addPill(Pills.PHANTOM, "Вы получаете фальшивый урон и получаете его снова через 15 и 30 секунд", "Фантомная Боль", "ru")
	EID:addPill(Pills.YUCK, "Создает гнилое сердце #В течение 30 секунд, каждое взятое красное сердце будет создавать синих мух", "Фу!", "ru")
	EID:addPill(Pills.YUM, "Создает красное сердце #В течение 30 секунд, каждое взятое красное сердце даст вам небольшое постоянное увеличение случайной характеристики, похожий на эффект {{Collectible671}} Карамельного Сердца", "Ням!", "ru")
end

								---------------------
								--- ENCYCLOPEDIA  ---
								---------------------

if Encyclopedia then	
	local ItemsWiki = {
		[Collectibles.ORDLIFE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Tears up"},
				{str = "Spawns an additional Mom/Dad related item in Treasure rooms alongside the presented items; only one item can be taken"},
			},
		},
		[Collectibles.COOKIECUTTER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Gives you one heart container and one broken heart "},
				{str = "Having 12 broken hearts kills you!"},
			},
		},
		[Collectibles.SINNERSHEART] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "+2 black hearts "},
				{str = "Damage +2 then x1.5"},
				{str = "Grants +2 range and -0.2 shotspeed "},
				{str = "Grants spectral and piercing tears"},
			},
		},
		[Collectibles.RUBIKSCUBE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "After each use, has a 5% (100% on 20-th use) chance to be 'solved', removed from the player and be replaced with a Magic Cube item"},
			},
		},
		[Collectibles.MAGICCUBE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Rerolls item pedestals "},
				{str = "Rerolled items can be drawn from any item pool"},
			},
		},
		[Collectibles.MAGICPEN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Double tap shooting button to spew a line of  creep in the direction you're firing "},
				{str = "Random permanent status effects is applied to enemies walking over that creep "},
				{str = "Has a 4 seconds cooldown"},
			},
		},
		[Collectibles.MARKCAIN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "On death, if you have any familiars, removes them instead and revives you "},
				{str = "On revival, you keep your heart containers, gain +".. tostring(StatUps.MARKCAIN_DMG) .. " DMG for each consumed familiar and gain invincibility"},
				{str = "Works only once!"},
			},
		},
		[Collectibles.TEMPERTANTRUM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "25% chance to enter Berserk state when taking damage "},
				{str = "While in this state, every enemy damaged has a 10% chance to be erased for the rest of the run"},
			},
		},
		[Collectibles.BAGOTRASH] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "A familiar that creates blue flies upon clearing a room "},
				{str = "Blocks enemy projectiles, and after blocking it has a chance to be destroyed and drop Breakfast or Nightsoil trinket "},
				{str = "The more floors it is not destroyed, the more flies it spawns"},
			},
		},
		[Collectibles.CHERUBIM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "A familiar that rapidly shoots tears with Godhead aura"},
			},
		},
		[Collectibles.CHERRYFRIENDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Killing an enemy has a 20% chance to drop cherry familiar on the ground "},
				{str = "Those cherries emit a charming fart when an enemy walks over them, and drop half a heart when a room is cleared"},
			},
		},
		[Collectibles.BLACKDOLL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon entering a new room, all enemies will be split in pairs. Dealing damage to one enemy in each pair will deal 60% of that damage to another enemy in that pair"},
			},
		},
		[Collectibles.BIRDOFHOPE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon dying you turn into invincible ghost and a bird flies out of room center in a random direction. Catching the bird in 5 seconds will save you and get you back to your death spot, otherwise you will die "},
				{str = "Every time you die, the bird will fly faster and faster, making it harder to catch her"},
			},
		},
		[Collectibles.ENRAGEDSOUL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Double tap shooting button to launch a ghost familiar in the direction you are firing "},
				{str = "The ghost will latch onto the first enemy it collides with, dealing damage over time for 7 seconds or until that enemy is killed "},
				{str = "The ghost's damage per hit starts at 7 and increases each floor "},
				{str = "The ghost can latch onto bosses aswell "},
				{str = "Has a 7 seconds cooldown"},
			},
		},
		[Collectibles.CEREMDAGGER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Damage x".. tostring(StatUps.CEREMDAGGER_DMG_MUL)},
				{str = "When shooting, 7% chance to launch a dagger that does no damage, but inflicts bleed on enemies "},
				{str = "All enemies that die while bleeding will drop Sacrificial Blood Consumable that gives you temporary DMG up"},
			},
		},
		[Collectibles.CEILINGSTARS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Grants you two Lemegeton wisps at the beginning of each floor and when sleeping in bed"},
			},
		},
		[Collectibles.QUASAR] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Consumes all item pedestals in the room and gives you 3 Lemegeton wisps for each item consumed"},
			},
		},
		[Collectibles.TWOPLUSONE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Every third shop item on the current floor will cost 1  penny "},
				{str = "Buying two items with hearts in one room makes all other items free"},
			},
		},
		[Collectibles.REDMAP] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Reveals location of Ultra Secret Room on all subsequent floors "},
				{str = "Any trinket left in a boss or treasure room will turn into Cracked Key, unless this is your first visit in such room"},
			},
		},
		[Collectibles.CHEESEGRATER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Removes one red heart container and gives you  +".. tostring(StatUps.GRATER_DMG) .. " Damage up and 3 Minisaacs"},
			},
		},
		[Collectibles.DNAREDACTOR] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Pills now have additional effects based on their color"},
			},
		},
		[Collectibles.TOWEROFBABEL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Destroys all obstacles in the current room and applies confusion to enemies in small radius around you "},
				{str = "Also blows the doors open and opens secret room entrances"},
			},
		},
		[Collectibles.BLESSOTDEAD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Prevents curses from appearing for the rest of the run "},
				{str = "Preventing a curse grants you  +".. tostring(StatUps.BLESS_DMG) .. " Damage up"},
			},
		},
		[Collectibles.TOYTANKS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 2 Toy Tanks familiars that roam around the room and attack enemies that are in their line of sight "},
				{str = "Green tank: rapidly shoots bullets at enemies from a further distance and moves more quickly "},
				{str = "Red tank: shoots rockets at enemies at a close range, moves slower"},
			},
		},
		[Collectibles.GUSTYBLOOD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Killing enemies grants you  tears and speed up "},
				{str = "The bonus is reset when entering a new room"},
			},
		},
		[Collectibles.REDBOMBER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs "},
				{str = "Grants explosion immunity "},
				{str = "Allows you to throw your bombs instead of placing them on the ground"},
			},
		},
		[Collectibles.MOTHERSLOVE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Grants you stat boosts for each familiar you own"},
				{str = "Some familiars grant greater stat boosts, and some do not grant them at all (e.g. blue flies, dips or Isaac's body parts)"},
			},
		},
		[Collectibles.CATINBOX] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "When entering a room with enemies, their health is halved for the first 3 seconds, and then restored back to full "},
				{str = "Doesn't work on bosses or minibosses"},
			},
		},
		[Collectibles.BOOKOFGENESIS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Removes a random item and spawns 3 items of the same quality "},
				{str = "Only one item can be taken "},
				{str = "Can't remove or spawn quest items"},
			},
		},
		[Collectibles.SCALPEL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Makes you shoot tears in the opposite direction "},
				{str = "From the front, you will frequently shoot bloody tears that deal x0.66 of your damage "},
				{str = "All other weapon types will still be fired from the front as well"},
			},
		},
		[Collectibles.KEEPERSPENNY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns a golden penny upon entering a new floor "},
				{str = "Shops will now sell 1-4 additional items that are drawn from shop, treasure or boss itempools"},
				{str = "If the shop is a Greed fight, it instead spawns 3-4 items when the miniboss dies"}
			},
		},
		[Collectibles.NERVEPINCH] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Shooting or moving for 8 seconds will trigger a nerve pinch "},
				{str = "You take fake damage and gain a permanent " .. tostring(StatUps.NERVEPINCH_SPEED) .. " speed down when that happens "},
				{str = "However, there is a 80% chance to activate your active item for free, even if it's uncharged "},
				{str = "One-time use and infinite use actives cannot be used that way"},
			},
		},
		[Collectibles.BLOODVESSELS[1]] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Taking damage doesn't actually hurt the player, instead filling the blood vessel "},
				{str = "This can be repeated 6 times until the vessel is full "},
				{str = "Once it's full, using it or taking damage will empty it and deal 3 and 3.5 hearts of damage to the player, respectively"},
			},
		},
		[Collectibles.SIBLINGRIVALRY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Orbital that switches between 2 different states every 15 seconds:"},
				{str = "Two orbitals that quickly rotate around Isaac"},
				{str = "One orbital that rotates slower and closer to Isaac, and periodically shoots teeth in random directions and spawns blood creep underneath it"},
				{str = "All orbitals block enemy shots and do contact damage"},
			},
		},
		[Collectibles.REDKING] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "After defeating a boss, red crawlspace will appear in a middle of a room"},
				{str = "Entering the crawlspace brings you to another bossfight of high difficulty. Victory rewards you a red item (from Ultra secret room pool)"},
				{str = "The crawlspace can be entered only once, but you can enter it whenever you want, not necessarily after defeating the main floor boss"},
				{str = "Bosses from chapters 2 and onward of the main path can be encountered; also includes a lot of double trouble bossfights"},
			},
		},
		[Collectibles.STARGAZERSHAT] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Summons the Stargazer beggar"},
				{str = "Can only be charged with soul hearts, similar to Alabaster Box"},
				{str = "2 soul hearts needed for full charge"},
			},
		},
		[Collectibles.BOTTOMLESSBAG] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon use, holds the bag in the air"},
				{str = "For 4 seconds, all nearby projectiles are sucked into the bag"},
				{str = "After 4 seconds, all sucked projecties are released as homing tears in your firing direction"},
				{str = "Tears released by the bag inherit all your tear effects (e.g. they are explosive if you have Ipecac)"},
				{str = "If the player doesn't hold a shooting button, the reflected tears are shot downwards"},
			},
		},
	}
	
	local TrinketsWiki = {
		[Trinkets.BASEMENTKEY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "While held, every Golden Chest has a 5% chance to be replaced with Old Chest"},
			},
		},
		[Trinkets.KEYTOTHEHEART] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "While held, every enemy has a chance to drop Flesh Chest upon death"},
				{str = "Flesh Chests hurt the player for half a heart when opened; this damage prioritizes red hearts"},
				{str = "Flesh Chests contain 1-4 pills/hearts or a random body-related item"},
			},
		},
		[Trinkets.JUDASKISS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Enemies touching you become targeted by other enemies (effect of Rotten Tomato item)"},
			},
		},
		[Trinkets.TRICKPENNY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Using coin, bomb or key on slots, beggars or locked chests has a 17% chance to not subtract it from your inventory count"},
			},
		},
		[Trinkets.SLEIGHTOFHAND] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon spawning, every coin has a 20% chance to be upgraded to a higher value"},
				{str = "The upgrade is as follows: penny -> doublepack pennies -> sticky nickel -> nickel -> dime -> lucky penny -> golden penny"},
			},
		},
		[Trinkets.GREEDSHEART] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Gives you one empty coin heart"},
				{str = "It is depleted before any of your normal hearts and can only be refilled by directly picking up money"},
			},
		},
		[Trinkets.ANGELSCROWN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "All new treasure rooms will have an angel item for sale instead of a normal item"},
				{str = "Angels spawned from statues will not drop Key Pieces!"},
				{str = "Angel items reroll into items from a treasure room pool"}
			},
		},
		[Trinkets.MAGICSWORD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "x2 DMG up while held "},
				{str = "Breaks when you take damage"},
				{str = "Having Duct Tape prevents it from breaking"},
			},
		},
		[Trinkets.WAITNO] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Does nothing, it's broken"},
			},
		},
		[Trinkets.EDENSLOCK] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon taking damage, one of your items rerolls into another random item"},
				{str = "Doesn't take away nor give you story items"},
			},
		},
		[Trinkets.CHALKPIECE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "When entering uncleared room, you will leave a trail of powder underneath for 5 seconds"},
				{str = "Enemies walking over this trail will be pushed back"},
			},
		},
		[Trinkets.ADAMSRIB] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Revives you as Eve when you die"},
				{str = "The Eve character receives 3 soul hearts and a Whore of Babylon item"}
			},
		},
		[Trinkets.NIGHTSOIL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "75% chance to prevent a curse when entering a new floor"},
			},
		},
		[Trinkets.BONEMEAL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "At the beginning of every new floor, grants:"},
				{str = "+10% DMG up"},
				{str = "Size increase "},
				{str = "Both damage and size up stay if you drop the trinket"},
			},
		},
		[Trinkets.TORNPAGE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Amplifies or changes book's activation effects, or makes them charge faster"},
				{str = "Anarchist Cookbook: spawns red bombs instead of troll bombs"},
				{str = "Bible: removes a broken heart"},
				{str = "Satanic Bible: prevents a devil deal from replacing a boss item"},
				{str = "Book of Revelations: prevents Harbingers from replacing floor bosses"},
				{str = "Book of the Dead: grants you a bone heart"},
				{str = "Book of Belial: grants Eye of Belial effect"},
				{str = "Telepathy for Dummies: grants Dunce Cap effect"},
				{str = "Monster Manual: summons friendly spiders, flies or dips on use"},
				{str = "Book of Sin: has a 1% chance to spawn an item instead of a pickup"},
				{str = "Book of Genesis: increases the number of options to 4"},
				{str = "Other books get +1 charge when used, effectively reducing their chargeup time"},
				{str = "Apart from natural spawns, this trinket has a 33% chance to spawn in libraries"},
			},
		},
		[Trinkets.EMPTYPAGE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Books now activate a random active item on use "},
				{str = "Doesn't work on How to Jump and doesn't proc dice and items that hurt or kill you"},
				{str = "Apart from natural spawns, this trinket has a 33% chance to spawn in libraries"},
			},
		},
		[Trinkets.BABYSHOES] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Reduces the size of all enemies by 20%"},
				{str = "This affects both sprite and hitbox"},
				{str = "Affects bosses too"},
			},
		},
	}
	
	local PillsWiki = {
		[Pills.ESTROGEN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Turns all your red health into blood clots "},
				{str = "Leaves you at one red heart, doesn't affect soul/black hearts"},
			},
		},
		[Pills.LAXATIVE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Makes you shoot out corn tears from behind for 3 seconds"},
			},
		},
		[Pills.PHANTOM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Makes Isaac take fake damage on pill use, then 15 and 30 seconds after"},
			},
		},
		[Pills.YUCK] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns a rotten heart "},
				{str = "For 30 seconds, every picked up red heart will spawn blue flies"},
			},
		},
		[Pills.YUM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns a red heart "},
				{str = "For 30 seconds, every picked up red heart will grant you small permanent stat upgrades, similar to Candy Heart effect"},
			},
		},
	}

	local PillsColors = {
		[Pills.ESTROGEN] = 9,
		[Pills.LAXATIVE] = 10,
		[Pills.PHANTOM] = 10,
		[Pills.YUCK] = 9,
		[Pills.YUM] = 9
	}
	
	local itemPools = {
		[Collectibles.ORDLIFE] = {Encyclopedia.ItemPools.POOL_BOSS},
		[Collectibles.COOKIECUTTER] = {Encyclopedia.ItemPools.POOL_DEMON_BEGGAR, Encyclopedia.ItemPools.POOL_CURSE},
		[Collectibles.RUBIKSCUBE] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_CRANE_GAME},
		[Collectibles.MAGICPEN] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_CRANE_GAME},
		[Collectibles.MARKCAIN] = {Encyclopedia.ItemPools.POOL_CURSE, Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.TEMPERTANTRUM] = {Encyclopedia.ItemPools.POOL_SECRET, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.BAGOTRASH] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BEGGAR, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[Collectibles.CHERUBIM] = {Encyclopedia.ItemPools.POOL_ANGEL, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[Collectibles.CHERRYFRIENDS] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.BLACKDOLL] = {Encyclopedia.ItemPools.POOL_CURSE, Encyclopedia.ItemPools.POOL_RED_CHEST},
		[Collectibles.BIRDOFHOPE] = {Encyclopedia.ItemPools.POOL_ANGEL},
		[Collectibles.ENRAGEDSOUL] = {Encyclopedia.ItemPools.POOL_DEVIL},
		[Collectibles.CEREMDAGGER] = {Encyclopedia.ItemPools.POOL_DEVIL},
		[Collectibles.CEILINGSTARS] = {Encyclopedia.ItemPools.POOL_SHOP},
		[Collectibles.QUASAR] = {Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ANGEL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.TWOPLUSONE] = {Encyclopedia.ItemPools.POOL_SHOP, Encyclopedia.ItemPools.POOL_SECRET},
		[Collectibles.REDMAP] = {Encyclopedia.ItemPools.POOL_SECRET, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.SINNERSHEART] = {Encyclopedia.ItemPools.POOL_DEVIL},
		[Collectibles.CHEESEGRATER] = {Encyclopedia.ItemPools.POOL_SHOP},
		[Collectibles.DNAREDACTOR] = {Encyclopedia.ItemPools.POOL_SECRET},
		[Collectibles.TOWEROFBABEL] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_CRANE_GAME},
		[Collectibles.BLESSOTDEAD] = {Encyclopedia.ItemPools.POOL_SECRET},
		[Collectibles.TOYTANKS] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[Collectibles.GUSTYBLOOD] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.REDBOMBER] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BOMB_BUM, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.MOTHERSLOVE] = {Encyclopedia.ItemPools.POOL_SHOP, Encyclopedia.ItemPools.POOL_BEGGAR, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.CATINBOX] = {Encyclopedia.ItemPools.POOL_TREASURE},
		[Collectibles.BOOKOFGENESIS] = {Encyclopedia.ItemPools.POOL_ANGEL, Encyclopedia.ItemPools.POOL_LIBRARY},
		[Collectibles.SCALPEL] = {Encyclopedia.ItemPools.POOL_DEMON_BEGGAR, Encyclopedia.ItemPools.POOL_RED_CHEST},
		[Collectibles.KEEPERSPENNY] = {Encyclopedia.ItemPools.POOL_SHOP, Encyclopedia.ItemPools.POOL_SECRET},
		[Collectibles.NERVEPINCH] = {Encyclopedia.ItemPools.POOL_TREASURE},
		[Collectibles.BLOODVESSELS[1]] = {Encyclopedia.ItemPools.POOL_DEMON_BEGGAR, Encyclopedia.ItemPools.POOL_CURSE},
		[Collectibles.SIBLINGRIVALRY] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[Collectibles.REDKING] = {Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[Collectibles.STARGAZERSHAT] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_SECRET}
	}

	local CardsWiki = {
		[PocketItems.SDDSHARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Invokes the effect of Spindown Dice"},
			},
		},
		[PocketItems.REDRUNE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Damages all enemies in a room, turns item pedestals into red permanent locusts and turns pickups into random locusts with a 50% chance"},
			},
		},
		[PocketItems.NEEDLEANDTHREAD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Removes one broken heart and grants one full heart container"},
			},
		},
		[PocketItems.QUEENOFDIAMONDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 1-12 random coins"},
				{str = "Coins could be nickels or dimes too"}
			},
		},
		[PocketItems.KINGOFSPADES] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Lose all your keys and spawn a number of pickups proportional to the amount of keys lost"},
				{str = "At least 12 keys is needed for a trinket, and at least 28 for an item "},
				{str = "If Isaac has Golden key, it is removed too and significantly increases total value"},
			},
		},
		[PocketItems.KINGOFCLUBS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Lose all your bombs and spawn a number of pickups proportional to the amount of bombs lost"},
				{str = "At least 12 bombs is needed for a trinket, and at least 28 for an item"},
				{str = "If Isaac has Golden bomb, it is removed too and significantly increases total value"},
			},
		},
		[PocketItems.KINGOFDIAMONDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Lose all your coins and spawn a number of pickups proportional to the amount of coins lost "},
				{str = "At least 15 coins is needed for a trinket, and at least 35 for an item"},
			},
		},
		[PocketItems.BAGTISSUE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "All pickups in a room are destroyed, and 8 most valuables pickups form an item quality based on their total weight; the item of such quality is then spawned "},
				{str = "The most valuable pickups are the rarest ones, e.g. eternal hearts or mega batteries"},
				{str = "If used in a room with less then 8 pickups, no item will spawn!"},
			},
		},
		[PocketItems.RJOKER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Teleports Isaac to a Black Market"},
			},
		},
		[PocketItems.REVERSECARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Invokes the effect of Glowing Hourglass"},
			},
		},
		[PocketItems.LOADEDDICE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "grants 10 Luck for the current room"},
			},
		},
		[PocketItems.BEDSIDEQUEEN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 1-12 random keys "},
				{str = "There is a small chance to spawn a charged key"},
			},
		},
		[PocketItems.QUEENOFCLUBS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 1-12 random bombs "},
				{str = "There is a small chance to spawn a double-pack bomb"},
			},
		},
		[PocketItems.JACKOFCLUBS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Bombs will drop more often from clearing rooms for current floor, and the average quality of bombs is increased"},
			},
		},
		[PocketItems.JACKOFDIAMONDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Coins will drop more often from clearing rooms for current floor, and the average quality of coins is increased"},
			},
		},
		[PocketItems.JACKOFSPADES] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Keys will drop more often from clearing rooms for current floor, and the average quality of keys is increased"},
			},
		},
		[PocketItems.JACKOFHEARTS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Hearts will drop more often from clearing rooms for current floor, and the average quality of hearts is increased"},
			},
		},
		[PocketItems.QUASARSHARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Damages all enemies in a room and turns every item pedestal into 3 Lemegeton wisps"},
			},
		},
		[PocketItems.BUSINESSCARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Summons a random monster, like ones from Friend Finder"},
			},
		},
		[PocketItems.SACBLOOD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Gives +1.25 DMG up that depletes over the span of 20 seconds"},
				{str = "Stackable"},
				{str = "Heals you for one red heart if you have Ceremonial Robes "},
				{str = "Damage depletes quicker the more Blood you used subsequently"},
			},
		},
		[PocketItems.LIBRARYCARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Activates a random book effect"},
			},
		},
		[PocketItems.MOMSID] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Charms all enemies in the current room"},
			},
		},
		[PocketItems.FUNERALSERVICES ] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns an Old Chest"},
			},
		},
		[PocketItems.ANTIMATERIALCARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Can be thrown similarly to Chaos Card"},
				{str = "If the card touches an enemy, that enemy is erased for the rest of the run"},
			},
		},
		[PocketItems.FIENDFIRE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Sacrifice your consumables for mass room destruction"},
				{str = "7-40 total: enemies take 15 damage and burn for 4 seconds"},
				{str = "41-80 total: the initital damage, the burning damage and burning duration are doubled; destroys obstacles around you"},
				{str = "80+ total: the burning damage and burning duration are quadrupled; produces a Mama Mega explosion"},
			},
		},
		[PocketItems.DEMONFORM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Increases your damage by 0.15 for every new uncleared room you enter"},
				{str = "The boost disappears when entering a new floor"},
			},
		},
	}
	
	local spriteToCard = {
		[PocketItems.SDDSHARD] = "Spindown Dice Shard",
		[PocketItems.REDRUNE] = "Red Rune",
		[PocketItems.NEEDLEANDTHREAD] = "Needle and Thread",
		[PocketItems.QUEENOFDIAMONDS] = "Queen of Diamonds",
		[PocketItems.KINGOFSPADES] = "King of Spades",
		[PocketItems.KINGOFCLUBS] = "King of Clubs",
		[PocketItems.KINGOFDIAMONDS] = "King of Diamonds",
		[PocketItems.BAGTISSUE] = "Bag Tissue",
		[PocketItems.RJOKER] = "Joker?",
		[PocketItems.REVERSECARD] = "Reverse Card",
		[PocketItems.LOADEDDICE] = "Loaded Dice",
		[PocketItems.BEDSIDEQUEEN] = "Bedside Queen",
		[PocketItems.QUEENOFCLUBS] = "Queen of Clubs",
		[PocketItems.JACKOFCLUBS] = "Jack of Clubs",
		[PocketItems.JACKOFDIAMONDS] = "Jack of Diamonds",
		[PocketItems.JACKOFSPADES] = "Jack of Spades",
		[PocketItems.JACKOFHEARTS] = "Jack of Hearts",
		[PocketItems.QUASARSHARD] = "Quasar Shard",
		[PocketItems.BUSINESSCARD] = "Business Card",
		[PocketItems.SACBLOOD] = "Sacrificial Blood",
		[PocketItems.LIBRARYCARD] = "Library Card",
		[PocketItems.ANTIMATERIALCARD] = "Antimaterial Card",
		[PocketItems.FUNERALSERVICES] = "Funeral Services",
		[PocketItems.MOMSID] = "Mom's ID",
		[PocketItems.FIENDFIRE] = "Fiend Fire",
		[PocketItems.DEMONFORM] = "Demon Form"
	}
	
	-- DO NOT touch that! 
	-- Just fill in the Wiki and itemPools tables with the desired item's entry, and it will show up in the Encyclopedia
	for i = Collectibles.ORDLIFE, Collectibles.SIBLINGRIVALRY do
		Encyclopedia.AddItem({Class = "Repentance Plus", ID = i, WikiDesc = ItemsWiki[i], Pools = itemPools[i]})
		--Isaac.DebugString('Item ' .. tostring(i) .. 's entry succesfully loaded into the encyclopedia')
	end
	
	for i = Trinkets.BASEMENTKEY, Trinkets.EMPTYPAGE do
		Encyclopedia.AddTrinket({Class = "Repentance Plus", ID = i, WikiDesc = TrinketsWiki[i]})
	end
	
	for i = Pills.ESTROGEN, Pills.YUCK do
		Encyclopedia.AddPill({Class = "Repentance Plus", ID = i, WikiDesc = PillsWiki[i], Color = PillsColors[i]})
	end
	
	for i = PocketItems.REDRUNE, PocketItems.JACKOFHEARTS do
		Encyclopedia.AddCard({Class = "Repentance Plus", ID = i, WikiDesc = CardsWiki[i], 
		Sprite = Encyclopedia.RegisterSprite("content/gfx/ui_cardfronts.anm2", tostring(spriteToCard[i]))})
	end
end

								----------------------
								--- SEWING MACHINE ---
								----------------------



								-- blacklisting some stuff ----------
								-- for Sodom & Gomorrah characters --

if XalumMods and XalumMods.SodomAndGomorrah then
	XalumMods.SodomAndGomorrah.AddBlacklistedSodomGomorrahItems({
		Collectibles.CEILINGSTARS,
		Collectibles.BIRDOFHOPE,
		Collectibles.MARKCAIN,
		Collectibles.STARGAZERSHAT
	})
	
	XalumMods.SodomAndGomorrah.AddBlacklistedSodomGomorrahTrinkets({
		Trinkets.KEYTOTHEHEART,
		Trinkets.TRICKPENNY,
		Trinkets.ADAMSRIB
	})
end


































