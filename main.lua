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
local MOD_VERSION = 1.19
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

-- helper effect for cripple debuffs
CripplingHandsHelper = Isaac.GetEntityVariantByName("Crippling Hands Helper")

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
local BASEMENTKEY_CHANCE = 12.5			-- chance to replace golden chest with an old chest
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
local FLESHCHEST_REPLACE_CHANCE = 33	-- chance for Flesh chests to replace mimic, spiked normally
local FLESHCHEST_OPEN_CHANCE = 33		-- chance to open Flesh chest 
local BLACKCHEST_SPAWN_CHANCE = 17		-- chance for Black chests to spawn when entering a devil room
local SCARLETCHEST_REPLACE_CHANCE = 10	-- chance for Scarlet chests to spawn
local STARGAZER_PAYOUT_CHANCE = 15		-- chance for Stargazer beggar to payout with an item
local STARGAZER_SPAWN_CHANCE = {
	['Arcade'] = 10,
	['Planetarium'] = 75
}
local BLOODYROCKS_REPLACE_CHANCE = 25	-- chance for Bloody (Ultra secret, Tainted) rocks to replace spiked rocks
local CRIPPLE_TEAR_CHANCE = 2			-- chance to cripple enemies by hitting them with your tears
local DARK_ARTS_CHANCE = 5				-- chance to activate Dark Arts if hit while having Key Knife trinket

-- cooldowns
local ENRAGED_SOUL_COOLDOWN = 7 * 60			-- cooldown for Enraged Soul familiar
local REDBOMBER_LAUNCH_COOLDOWN = 1 * 60 		-- cooldown for launching red bombs
local MAGICPEN_CREEP_COOLDOWN = 4 * 60 			-- cooldown for Magic Pen creep
local NERVEPINCH_HOLD = 60 * 8					-- cooldown for Nerve Pinch
local SIBLING_STATE_SWITCH_COOLDOWN = 15 * 30	-- cooldown for switching Sibling forms

									-----------------
									----- ENUMS -----
									-----------------

Costumes = {
	-- add ONLY NON-PERSISTENT COSTUMES here, because persistent costumes work without lua
	BIRDOFHOPE = Isaac.GetCostumeIdByPath("gfx/characters/costume_004_birdofhope.anm2")
}

CustomTearVariants = {
	CEREMONIAL_BLADE = Isaac.GetEntityVariantByName("Ceremonial Dagger Tear"),
	ANTIMATERIAL_CARD = Isaac.GetEntityVariantByName("Antimaterial Card Tear"),
	REJECTED_BABY = Isaac.GetEntityVariantByName("Rejected Baby Tear")
}

CustomFamiliars = {
	BAG_O_TRASH = Isaac.GetEntityVariantByName("Bag O' Trash"),
	CHERUBIM = Isaac.GetEntityVariantByName("Cherubim"),
	CHERRY = Isaac.GetEntityVariantByName("Cherry"),
	BIRD = Isaac.GetEntityVariantByName("Bird of Hope"),
	ENRAGED_SOUL = Isaac.GetEntityVariantByName("Enraged Soul"),
	TOY_TANK_1 = Isaac.GetEntityVariantByName("Toy Tank 1"),
	TOY_TANK_2 = Isaac.GetEntityVariantByName("Toy Tank 2"),
	SIBLING_1 = Isaac.GetEntityVariantByName("Peaceful Sibling 1"),
	SIBLING_2 = Isaac.GetEntityVariantByName("Peaceful Sibling 2"),
	FIGHTING_SIBLINGS = Isaac.GetEntityVariantByName("Fighting Siblings"),
	REJECTION_FETUS = Isaac.GetEntityVariantByName("Rejection Fetus")
}

CustomCollectibles = {
	ORDINARY_LIFE = Isaac.GetItemIdByName("Ordinary Life"),
	COOKIE_CUTTER = Isaac.GetItemIdByName("Cookie Cutter"),
	RUBIKS_CUBR = Isaac.GetItemIdByName("Rubik's Cube"),
	MAGIC_CUBE = Isaac.GetItemIdByName("Magic Cube"),
	MAGIC_PEN = Isaac.GetItemIdByName("Magic Pen"),					
	SINNERS_HEART = Isaac.GetItemIdByName("Sinner's Heart"),
	MARK_OF_CAIN = Isaac.GetItemIdByName("The Mark of Cain"),			
	BAG_O_TRASH = Isaac.GetItemIdByName("Bag-o-Trash"),
	TEMPER_TANTRUM = Isaac.GetItemIdByName("Temper Tantrum"),
	CHERRY_FRIENDS = Isaac.GetItemIdByName("Cherry Friends"),
	CHERUBIM = Isaac.GetItemIdByName("Cherubim"),
	BLACK_DOLL = Isaac.GetItemIdByName("Black Doll"),
	BIRD_OF_HOPE = Isaac.GetItemIdByName("A Bird of Hope"),
	ENRAGED_SOUL = Isaac.GetItemIdByName("Enraged Soul"),
	CEREMONIAL_BLADE = Isaac.GetItemIdByName("Ceremonial Blade"),
	CEILING_WITH_THE_STARS = Isaac.GetItemIdByName("Ceiling with the Stars"),
	QUASAR = Isaac.GetItemIdByName("Quasar"),
	TWO_PLUS_ONE = Isaac.GetItemIdByName("2+1"),
	RED_MAP = Isaac.GetItemIdByName("Red Map"),
	CHEESE_GRATER = Isaac.GetItemIdByName("Cheese Grater"),
	DNA_REDACTOR = Isaac.GetItemIdByName("DNA Redactor"),
	TOWER_OF_BABEL = Isaac.GetItemIdByName("Tower of Babel"),
	BLESS_OF_THE_DEAD = Isaac.GetItemIdByName("Bless of the Dead"),
	TANK_BOYS = Isaac.GetItemIdByName("Tank Boys"),
	GUSTY_BLOOD = Isaac.GetItemIdByName("Gusty Blood"),
	RED_BOMBER = Isaac.GetItemIdByName("Red Bomber"),
	MOTHERS_LOVE = Isaac.GetItemIdByName("Mother's Love"),
	CAT_IN_A_BOX = Isaac.GetItemIdByName("A Cat in the Box"),
	BOOK_OF_GENESIS = Isaac.GetItemIdByName("Book of Genesis"),
	SCALPEL = Isaac.GetItemIdByName("A Scalpel"),
	KEEPERS_PENNY = Isaac.GetItemIdByName("Keeper's Penny"),
	NERVE_PINCH = Isaac.GetItemIdByName("Nerve Pinch"),
	BLOOD_VESSELS = { 
		Isaac.GetItemIdByName("Blood Vessel"),
		Isaac.GetItemIdByName("Empty Blood Vessel"),
		Isaac.GetItemIdByName("Stained Blood Vessel"),
		Isaac.GetItemIdByName("Half Empty Blood Vessel"),
		Isaac.GetItemIdByName("Brimming Blood Vessel"),
		Isaac.GetItemIdByName("Full Blood Vessel"),
		Isaac.GetItemIdByName("Overflowing Blood Vessel") 
	},
	SIBLING_RIVALRY = Isaac.GetItemIdByName("Sibling Rivalry"),
	RED_KING = Isaac.GetItemIdByName("Red King"),
	STARGAZERS_HAT = Isaac.GetItemIdByName("Stargazer's Hat"),
	BOTTOMLESS_BAG = Isaac.GetItemIdByName("Bottomless Bag"),
	CROSS_OF_CHAOS = Isaac.GetItemIdByName("The Cross of Chaos"),
	REJECTION = Isaac.GetItemIdByName("Rejection"),
	REJECTION_P = Isaac.GetItemIdByName("Rejection (passive)"),
	AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel"),
	SOUL_BOND = Isaac.GetItemIdByName("Soul Bond"),
	ANGELS_WINGS = Isaac.GetItemIdByName("Angel's Wings"),
	HAND_ME_DOWNS = Isaac.GetItemIdByName("Hand-Me-Downs")
}

CustomTrinkets = {
	BASEMENT_KEY = Isaac.GetTrinketIdByName("Basement Key"),
	KEY_TO_THE_HEART = Isaac.GetTrinketIdByName("Key to the Heart"),
	TRICK_PENNY = Isaac.GetTrinketIdByName("Trick Penny"),
	JUDAS_KISS = Isaac.GetTrinketIdByName("Judas' Kiss"),
	SLEIGHT_OF_HAND = Isaac.GetTrinketIdByName("Sleight of Hand"),
	GREEDS_HEART = Isaac.GetTrinketIdByName("Greed's Heart"),
	ANGELS_CROWN = Isaac.GetTrinketIdByName("Angel's Crown"),
	PIECE_OF_CHALK = Isaac.GetTrinketIdByName("A Piece of Chalk"),
	MAGIC_SWORD = Isaac.GetTrinketIdByName("Magic Sword"),
	WAIT_NO = Isaac.GetTrinketIdByName("Wait, No!"),
	EDENS_LOCK = Isaac.GetTrinketIdByName("Eden's Lock"),
	ADAMS_RIB = Isaac.GetTrinketIdByName("Adam's Rib"),
	NIGHT_SOIL = Isaac.GetTrinketIdByName("Night Soil"),
	TORN_PAGE = Isaac.GetTrinketIdByName("Torn Page"),
	BONE_MEAL = Isaac.GetTrinketIdByName("Bone Meal"),
	EMPTY_PAGE = Isaac.GetTrinketIdByName("Empty Page"),
	BABY_SHOES = Isaac.GetTrinketIdByName("Baby Shoes"),
	KEY_KNIFE = Isaac.GetTrinketIdByName("Key Knife")
}

CustomConsumables = {
	JOKER_Q = Isaac.GetCardIdByName("Joker?"),
	SPINDOWN_DICE_SHARD = Isaac.GetCardIdByName("Spindown Dice Shard"),
	UNO_REVERSE_CARD = Isaac.GetCardIdByName("Reverse Card"),
	RED_RUNE = Isaac.GetCardIdByName("Red Rune"),
	KING_OF_SPADES = Isaac.GetCardIdByName("King of Spades"),
	KING_OF_CLUBS = Isaac.GetCardIdByName("King of Clubs"),
	KING_OF_DIAMONDS = Isaac.GetCardIdByName("King of Diamonds"),
	NEEDLE_AND_THREAD = Isaac.GetCardIdByName("Needle and Thread"),
	QUEEN_OF_DIAMONDS = Isaac.GetCardIdByName("Queen of Diamonds"),
	QUEEN_OF_CLUBS = Isaac.GetCardIdByName("Queen of Clubs"),
	BAG_TISSUE = Isaac.GetCardIdByName("Bag Tissue"),
	LOADED_DICE = Isaac.GetCardIdByName("Loaded Dice"),
	JACK_OF_DIAMONDS = Isaac.GetCardIdByName("Jack of Diamonds"),
	JACK_OF_CLUBS = Isaac.GetCardIdByName("Jack of Clubs"),
	JACK_OF_SPADES = Isaac.GetCardIdByName("Jack of Spades"),
	JACK_OF_HEARTS = Isaac.GetCardIdByName("Jack of Hearts"),
	BEDSIDE_QUEEN = Isaac.GetCardIdByName("Bedside Queen"),
	QUASAR_SHARD = Isaac.GetCardIdByName("Quasar Shard"),
	BUSINESS_CARD = Isaac.GetCardIdByName("Business Card"),
	SACRIFICIAL_BLOOD = Isaac.GetCardIdByName("Sacrificial Blood"),
	FLY_PAPER = Isaac.GetCardIdByName("Flypaper"),
	LIBRARY_CARD = Isaac.GetCardIdByName("Library Card"),
	MOMS_ID = Isaac.GetCardIdByName("Mom's ID"),
	FUNERAL_SERVICES = Isaac.GetCardIdByName("Funeral Services"),
	ANTIMATERIAL_CARD = Isaac.GetCardIdByName("Antimaterial Card"),
	FIEND_FIRE = Isaac.GetCardIdByName("Fiend Fire"),
	DEMON_FORM = Isaac.GetCardIdByName("Demon Form"), 
	MIRRORED_LANDSCAPE = Isaac.GetCardIdByName("Mirrored Landscape")
}

CustomPickups = {
	FLESH_CHEST = Isaac.GetEntityVariantByName("Flesh Chest"),
	SCARLET_CHEST = Isaac.GetEntityVariantByName("Scarlet Chest"),
	BLACK_CHEST = Isaac.GetEntityVariantByName("Black Chest"),
	-- tainted hearts
	TaintedHearts = {
		HEART_BROKEN  = 84,
		HEART_DAUNTLESS = 85,
		HEART_HOARDED  = 86,
		HEART_SOILED = 88,
		HEART_BENIGHTED  = 91,
		HEART_ENIGMA  = 92,
		HEART_CAPRICIOUS  = 93,
		HEART_EMPTY = 97,
		HEART_FETTERED  = 98,
		HEART_ZEALOT = 99,
		HEART_DESERTED  = 100
	},
	SLOT_STARGAZER = Isaac.GetEntityVariantByName("Stargazer")
}

CustomPills = {
	ESTROGEN = Isaac.GetPillEffectByName("Estrogen Up"),
	LAXATIVE = Isaac.GetPillEffectByName("Laxative"),
	PHANTOM_PAINS = Isaac.GetPillEffectByName("Phantom Pains"),
	YUM = Isaac.GetPillEffectByName("Yum!"),
	YUCK = Isaac.GetPillEffectByName("Yuck!")
}

--[[
local Unlocks = { 
	["21"] = { --T.Isaac
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.UNO_REVERSE_CARD}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.ORDINARY_LIFE}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = CustomCollectibles.RUBIKS_CUBR}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = CustomTrinkets.BASEMENT_KEY}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.SPINDOWN_DICE_SHARD}
	},
	["22"] = { --T.Maggy
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.QUEEN_OF_DIAMONDS}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.CHERRY_FRIENDS}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.COOKIE_CUTTER}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = 350, SubType = CustomTrinkets.KEY_TO_THE_HEART}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.NEEDLE_AND_THREAD}
	},
	["23"] = { --T.Cain
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.MARK_OF_CAIN}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = 350, SubType = CustomTrinkets.SLEIGHT_OF_HAND}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = 350, SubType = CustomTrinkets.TRICK_PENNY}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.BAG_TISSUE}
	},
	["24"] = { --T.Judas
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.JACK_OF_HEARTS}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.CEREMONIAL_BLADE}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = 350, SubType = CustomCollectibles.BLACK_DOLL}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = 350, SubType = CustomTrinkets.JUDAS_KISS}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.SACRIFICIAL_BLOOD}
	},
	["25"] = {	--T.???
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.FLY_PAPER}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.BAG_O_TRASH}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["26"] = {	--T.Eve
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.BEDSIDE_QUEEN}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Blue Baby"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}, 
		["Greed"] = {Unlocked = false, Type = 5, Variant = nil, SubType = nil}
	},
	["27"] = {	--T.Samson
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.JACK_OF_CLUBS}, 
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.TEMPER_TANTRUM}, 
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
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.JACK_OF_SPADES}, 
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
		["Boss Rush"] = {Unlocked = false, Type = 5, Variant = 300, SubType = CustomConsumables.QUEEN_OF_CLUBS}, 
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
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.SINNERS_HEART}, 
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
		["Satan"] = {Unlocked = false, Type = 5, Variant = 100, SubType = CustomCollectibles.CEILING_WITH_THE_STARS}, 
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

CustomItempools = {
	FLESH_CHEST = { 
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
		680, -- Montezuma's Revenge
		688, -- Inner Child
		695, -- Bloody Gust
		725, -- IBS
		729, -- Decap Attack
		730, -- Glass Eye
		731 -- Stye
	},
	FLESHCHEST_trinkets = {
		TrinketType.TRINKET_PINKY_EYE,
		TrinketType.TRINKET_UMBILICAL_CORD,
		TrinketType.TRINKET_CHILDS_HEART,
		TrinketType.TRINKET_CANCER,
		TrinketType.TRINKET_LUCKY_TOE,
		TrinketType.TRINKET_ISAACS_HEAD,
		TrinketType.TRINKET_JUDAS_TONGUE,
		TrinketType.TRINKET_CAINS_EYE,
		TrinketType.TRINKET_LEFT_HAND,
		TrinketType.TRINKET_TONSIL,
		TrinketType.TRINKET_NOSE_GOBLIN,
		TrinketType.TRINKET_STEM_CELL
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
	BLACK_CHEST = {
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
		CollectibleType.COLLECTIBLE_BLACK_POWDER,
		CollectibleType.COLLECTIBLE_MY_SHADOW,
		CollectibleType.COLLECTIBLE_CHARM_VAMPIRE,
		CollectibleType.COLLECTIBLE_DEAD_BIRD,
		CollectibleType.COLLECTIBLE_DEATHS_TOUCH,
		CustomCollectibles.BLACK_DOLL,
		CustomCollectibles.ENRAGED_SOUL
	},
	STARGAZER = {
		CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
		299,300,301,302,303,304,305,306,307,308,309,318,	-- zodiac signs
		CollectibleType.COLLECTIBLE_MAGIC_8_BALL,
		CollectibleType.COLLECTIBLE_DECK_OF_CARDS,
		588,589,590,591,592,593,594,595,596,597,598 		-- planets
	}
}

DropTables = {
	BLACK_CHEST = {
		{40, {{PickupVariant.PICKUP_GRAB_BAG, 2}}},
		{60, {{PickupVariant.PICKUP_GRAB_BAG, 2}, {PickupVariant.PICKUP_GRAB_BAG, 2}}},
		{80, {{20, 1}, {20, 1}, {20, 1}}},
		{90, {{PickupVariant.PICKUP_GRAB_BAG, 2}, {300, CustomConsumables.SPINDOWN_DICE_SHARD}}},
		{100, {{PickupVariant.PICKUP_GRAB_BAG, 2}, {300, Card.RUNE_BLACK}}}
	},
	BLOODYROCKS = {
		{20, {{300, Card.CARD_CRACKED_KEY}, {300, CustomConsumables.RED_RUNE}}},
		{45, {{300, CustomConsumables.RED_RUNE}, {10, HeartSubType.HEART_FULL}}},
		{65, {{10, HeartSubType.HEART_FULL}, {10, HeartSubType.HEART_FULL}}},
		{70, {{CustomPickups.SCARLET_CHEST, 0}}},
		{100, {{10, HeartSubType.HEART_FULL}, {300, Card.CARD_CRACKED_KEY}}},
	}
}

CustomStatups = {
	SINNERSHEART_DMG_MUL = 1.5,
	SINNERSHEART_DMG_ADD = 2,
	SINNERSHEART_SHSP = -0.2,
	SINNERSHEART_RANGE = 2, -- v1.7.5 patch fixed range (NOTE that you need to multiply it by 40 (grid length) when you apply it in MC_EVALUATE_CACHE)
	MARKCAIN_DMG = 0.66,
	LOADED_DICE_LUCK = 10,
	SACBLOOD_DMG = 1.25,
	MAGICSWORD_DMG_MUL = 2,
	GRATER_DMG = 0.5,
	BLESS_DMG = 0.75,
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
	DEMONFORM_DAMAGE = 0.15,
	HANDMEDOWNS_SPEED = 0.2
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
		[HeartSubType.HEART_ROTTEN] = 5,
		[CustomPickups.TaintedHearts.HEART_BROKEN] = 6,
		[CustomPickups.TaintedHearts.HEART_HOARDED] = 4,
		[CustomPickups.TaintedHearts.HEART_BENIGHTED] = 6,
		[CustomPickups.TaintedHearts.HEART_CAPRICIOUS] = 6,
		[CustomPickups.TaintedHearts.HEART_ENIGMA] = 6,
		[CustomPickups.TaintedHearts.HEART_FETTERED] = 5,
		[CustomPickups.TaintedHearts.HEART_DESERTED] = 4
	},
	[PickupVariant.PICKUP_COIN] = { 
		[CoinSubType.COIN_PENNY] = 1,
		[CoinSubType.COIN_NICKEL] = 3,
		[CoinSubType.COIN_DIME] = 5,
		[CoinSubType.COIN_DOUBLEPACK] = 2,
		[CoinSubType.COIN_LUCKYPENNY] = 7,
		[CoinSubType.COIN_GOLDEN] = 5
	},
	[PickupVariant.PICKUP_KEY] = {
		[KeySubType.KEY_NORMAL] = 1,
		[KeySubType.KEY_GOLDEN] = 5,
		[KeySubType.KEY_DOUBLEPACK] = 3,
		[KeySubType.KEY_CHARGED] = 5
	},
	[PickupVariant.PICKUP_BOMB] = {
		[BombSubType.BOMB_NORMAL] = 1,
		[BombSubType.BOMB_DOUBLEPACK] = 2,
		[BombSubType.BOMB_GOLDEN] = 5
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
	p:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(p), 24)
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
	
	-- for Mother's Love, CustomFamiliars will grant stronger or weaker stat boosts, depending on their rarity and effectiveness
	-- all Repentance+ CustomFamiliars have to be listed here
	-- all vanilla CustomFamiliars unlisted do NOT grant stat boosts (e.g. spiders, flies, dips, familiar spawned from CustomTrinkets and Isaac's body parts)
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
		[CustomFamiliars.BAG_O_TRASH] = 1,
		[CustomFamiliars.CHERUBIM] = 1,
		[CustomFamiliars.CHERRY] = 0,
		[CustomFamiliars.BIRD] = 0,
		[CustomFamiliars.ENRAGED_SOUL] = 0,
		[CustomFamiliars.TOY_TANK_1] = 0.75,
		[CustomFamiliars.TOY_TANK_2] = 0.75,
		[CustomFamiliars.SIBLING_1] = 0.75,
		[CustomFamiliars.SIBLING_2] = 0.75,
		[CustomFamiliars.FIGHTING_SIBLINGS] = 1.5,
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
				[StageType.STAGETYPE_REPENTANCE] = "ashpit",
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

local function isCollidingWithAstralChain(entity)
	if not entity:IsVulnerableEnemy() or entity:GetData()['isChainedToPlayer'] then return end
	if #Isaac.FindByType(865, 10, 1, false, false) == 0 then return end
	
	for _, chain in pairs(Isaac.FindByType(865, 10, 1, true, false)) do
		if not (chain.Target and chain.Parent) then chain:Remove() return end
		local Vector1 = (chain.Parent.Position - chain.Target.Position)
		local Vector2 = (entity.Position - chain.Target.Position)
		
		if math.abs(Vector1:GetAngleDegrees() - Vector2:GetAngleDegrees()) < 7.5 and Vector1:Length() > Vector2:Length() then
			return true
		else
			return false
		end
	end
end
local function HeartRender(player)
	local player = game:GetPlayer(0) 
	local TopVector = Vector(0,0)
	local level = game:GetLevel()
	local hearts = 0
	hearts = math.floor((player:GetMaxHearts() + player:GetSoulHearts()) /2  + player:GetBoneHearts()+0.5) 
   	if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= LevelCurse.CURSE_OF_THE_UNKNOWN then
  		if CustomData.TaintedHearts.ZEALOT > 0 then
   			local ZealotSprite = Sprite()
   			ZealotSprite:Load("gfx/ui/ui_taintedhearts.anm2", true)
   			ZealotSprite:LoadGraphics()
   			ZealotSprite:Play("Zealot", true)  		
   			local HeartRenderOffset = Options.HUDOffset * Vector(20, 12)
        		for i = hearts+1-CustomData.TaintedHearts.ZEALOT, hearts do
            			if (i < 7) then
                			TopVector = Vector((i-1)*12 + 48, 12)
            			elseif (i < 13) then
                			TopVector = Vector((i-7)*12 + 48, 22)
            			else
            	 	   		TopVector = Vector((i-13)*12 + 48, 30)
            			end
            			ZealotSprite:Render(TopVector+Vector(1, 1)+HeartRenderOffset, Vector.Zero, Vector.Zero)
            			ZealotSprite:Update()
        		end
    		end

    		if CustomData.TaintedHearts.EMPTY > 0 then
   			local EmptySprite = Sprite()
   			EmptySprite:Load("gfx/ui/ui_taintedhearts.anm2", true)
   			EmptySprite:LoadGraphics()
   			EmptySprite:Play("Empty")
   			local hearts = math.floor((player:GetMaxHearts() + player:GetSoulHearts()) /2  + player:GetBoneHearts()+0.5) 
   			local HeartRenderOffset = Options.HUDOffset * Vector(20, 12)
        		for i = hearts+1-CustomData.TaintedHearts.EMPTY, hearts do
            			if (i < 7) then
               				TopVector = Vector((i-1)*12 + 48, 12)
            			elseif (i < 13) then
         	    			TopVector = Vector((i-7)*12 + 48, 22)
            			else
                			TopVector = Vector((i-13)*12 + 48, 30)
            			end
            			EmptySprite:Render(TopVector+Vector(1, 1)+HeartRenderOffset, Vector.Zero, Vector.Zero)
            			EmptySprite:Update()
        		end
    		end
	end
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
	game:GetItemPool():RemoveTrinket(CustomTrinkets.WAIT_NO)
		
	if not Continued then
		hideErrorMessage = false
		noCustomHearts = false
		
		CustomData = {
			Items = {
				BIRD_OF_HOPE = {NumRevivals = 0, BirdCaught = true},
				RUBIKS_CUBR = {Counter = 0},
				MARK_OF_CAIN = nil,
				BAG_O_TRASH = {Levels = 0},
				TEMPER_TANTRUM = {ErasedEnemies = {}, SuperBerserkState = false},
				ENRAGED_SOUL = {SoulLaunchCooldown = nil, AttachedEnemy = nil},
				CEILING_WITH_THE_STARS = {SleptInBed = false},
				TWO_PLUS_ONE = {ItemsBought_COINS = 0, ItemsBought_HEARTS = 0},
				CHEESE_GRATER = {NumUses = 0},
				BLESS_OF_THE_DEAD = {NumUses = 0},
				GUSTY_BLOOD = {CurrentTears = 0, CurrentSpeed = 0},
				RED_BOMBER = {BombLaunchCooldown = 0},
				MAGIC_PEN = {CreepSpewCooldown = nil},
				CAT_IN_A_BOX = {RoomEnterFrame = nil},
				BOOK_OF_GENESIS = {Index = 5},
				MOTHERS_LOVE = {NumStats = 0, NumFriends = 0},
				BLOODVESSEL = {DamageFlag = false},
				NERVE_PINCH = {Hold = 300, NumTriggers = 0},
				RED_KING = {IsInRedKingRoom = false, DescendedRedCrawlspace = false, DefeatedRedKingBoss = false},
				BOTTOMLESS_BAG = {UseFrame = 0, TearCount = 0, Data = false}
			},
			Cards = {
				JACK = nil,
				SACRIFICIAL_BLOOD = {Data = false, NumUses = 0},
				DEMON_FORM = {NumUses = 0}
			},
			CustomTrinkets = {
				GREEDS_HEART = "CoinHeartEmpty",
				PIECE_OF_CHALK = {RoomEnterFrame = 0},
				TORN_PAGE = {trinketSeen = false},
				EMPTY_PAGE = {trinketSeen = false},
				BONE_MEAL = {Levels = 0}
			},
			CustomPills = {
				LAXATIVE = {UseFrame = nil},
				YUCK = {UseFrame = -900},
				YUM = {NumLuck = 0, NumDamage = 0, NumRange = 0, NumTears = 0, UseFrame = -900},
				PHANTOM_PAINS = {UseFrame = -900}
			},
			NumTaintedRocks = 0,
			FleshChestConsumedHP = 0,
			TaintedHearts = {
				EMPTY = 0,
				ZEALOT = 0
			}
		}
		
		if CustomData then 
			print("Repentance Plus mod v" .. tostring(MOD_VERSION) .. " initialized")
			print("To prevent Tainted hearts from replacing vanilla hearts, type `customhearts_none` into the console")
		end
		
		--[[ Spawn items/CustomTrinkets or turn on debug commands for testing here if necessary
		! DEBUG: 3 - INFINITE HP, 4 - HIGH DAMAGE, 8 - INFINITE CHARGES, 10 - INSTAKILL ENEMIES !
		
		Isaac.Spawn(5, 350, CustomTrinkets.TestTrinket, Isaac.GetFreeNearPosition(Vector(320,280), 10.0), Vector.Zero, nil)
		Isaac.Spawn(5, 100, CustomCollectibles.TestCollectible, Isaac.GetFreeNearPosition(Vector(320,280), 10.0), Vector.Zero, nil)
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
end
rplus:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, rplus.PreGameExit)

						-- MC_EXECUTE_CMD --											
						--------------------
function rplus:OnCommandExecute(command, args)
	if command == 'hide' then
		hideErrorMessage = true
		print('Error message hidden. To see it again, type `show` into the console')
	elseif command == 'show' then
		hideErrorMessage = false
	end
	
	if command == "customhearts_none" then
		noCustomHearts = true
		print('No more hearts from Repentance Plus mod! To be able to see them again, type `customhearts_all` into the console')
	elseif command == "customhearts_all" then
		noCustomHearts = false
		print('Tainted hearts are back! To prevent them from spawning, type `customhearts_none` into the console')
	end
end
rplus:AddCallback(ModCallbacks.MC_EXECUTE_CMD, rplus.OnCommandExecute)

						-- MC_POST_GAME_END --											
						---------------------
function rplus:GameEnded(isGameOver)
	handmedownsstage = 0
    for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local maxid = Isaac.GetItemConfig():GetCollectibles().Size - 1
		
		if player:HasCollectible(CustomCollectibles.HAND_ME_DOWNS) then
			handmedownsstage = game:GetLevel():GetStage()
			HandMeDownsItems = {} 
			for i=1, maxid do
				if player:HasCollectible(i) and 
				Isaac.GetItemConfig():GetCollectible(i).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST and 
				i ~= CustomCollectibles.HAND_ME_DOWNS then
					table.insert(HandMeDownsItems, i)
				end
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_GAME_END, rplus.GameEnded)	


						-- MC_GET_SHADER_PARAMS --										
						--------------------------
function rplus:GetShaderParams(shaderName)
	local player = game:GetPlayer(0) -- 
    	if shaderName == 'Hearts' then
    		HeartRender(player)
        	return nil
	end
end
rplus:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, rplus.GetShaderParams)


						-- MC_POST_NEW_LEVEL --										
						-----------------------
function rplus:OnNewLevel()
	local level = game:GetLevel()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if CustomData then
			CustomData.Cards.JACK = nil
			CustomData.NumTaintedRocks = 0
			
			if player:GetData()['usedDemonForm'] then
				CustomData.Cards.DEMON_FORM.NumUses = 0
				player:GetData()['usedDemonForm'] = false
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
			
			CustomData.Items.CEILING_WITH_THE_STARS.SleptInBed = false
			CustomData.Items.RED_KING.DefeatedRedKingBoss = false
			
			if player:HasCollectible(CustomCollectibles.BAG_O_TRASH) then
				CustomData.Items.BAG_O_TRASH.Levels = CustomData.Items.BAG_O_TRASH.Levels + 1
			end
			
			for i = 1, CustomData.TaintedHearts.EMPTY do
				Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 0, player.Position, Vector.Zero, nil)	
			end 

			-- for i = 1, CustomData.TaintedHearts.ZEALOT - math.floor(CustomData.TaintedHearts.ZEALOT / 2) do
				-- repeat 
					-- newID = GetUnlockedVanillaCollectible()
				-- until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
				
				-- player:AddItemWisp(newID, player.Position, true)
			-- end
		end
		
		if player:HasCollectible(CustomCollectibles.RED_MAP) then
			local USR = level:GetRoomByIdx(level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, true, RNG(), true))
			
			if USR.Data and USR.Data.Type == RoomType.ROOM_ULTRASECRET and USR.DisplayFlags & 1 << 2 == 0 then
				USR.DisplayFlags = USR.DisplayFlags | 1 << 2
				level:UpdateVisibility()
			end
		end
		
		if player:HasCollectible(CustomCollectibles.CEILING_WITH_THE_STARS) then
			for i = 1, 2 do
				repeat 
					newID = GetUnlockedVanillaCollectible()
				until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
				player:AddItemWisp(newID, player.Position, true)
			end
		end
		
		if player:HasCollectible(CustomCollectibles.TWO_PLUS_ONE) then
			CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS = 0
		end
		
		if player:HasTrinket(CustomTrinkets.BONE_MEAL) then
			CustomData.CustomTrinkets.BONE_MEAL.Levels = CustomData.CustomTrinkets.BONE_MEAL.Levels + 1
			player:UsePill(PillEffect.PILLEFFECT_LARGER, PillColor.PILL_NULL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		end
		
		if player:HasCollectible(CustomCollectibles.KEEPERS_PENNY) then
			Isaac.Spawn(5, 20, CoinSubType.COIN_GOLDEN, Vector(320, 320), Vector.Zero, nil)
		end
		
		if level:GetStage() == handmedownsstage then 
			for i = 1, 3 do 
				if #HandMeDownsItems > 0 then 
					local spawneditem = HandMeDownsItems[math.random(#HandMeDownsItems)]
					Isaac.Spawn(5, 100, spawneditem, Vector(408+36*i,100), Vector.Zero, nil):ToPickup()
					for i, item in ipairs(HandMeDownsItems) do
   						if spawneditem == item then
   							table.remove(HandMeDownsItems, i)
   						end
					end
				end
			end		
			handmedownsstage = 0
			HandMeDownsItems = {}	
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
		
		if player:HasCollectible(CustomCollectibles.ORDINARY_LIFE) and room:GetType() == RoomType.ROOM_TREASURE 
		and room:IsFirstVisit() and not room:IsMirrorWorld() then
			momNDadItem = Isaac.Spawn(5, 100, CustomItempools.MOMNDAD[math.random(#CustomItempools.MOMNDAD)], room:FindFreePickupSpawnPosition(Vector(320,280), 1, true, false), Vector.Zero, nil):ToPickup()
			
			momNDadItem.OptionsPickupIndex = 3
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
					entity:ToPickup().OptionsPickupIndex = 3
				end
			end	
		end
		
		if player:HasCollectible(CustomCollectibles.BLACK_DOLL) and room:IsFirstVisit() and Isaac.CountEnemies() > 1 then
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
		
		for _, entity in pairs(Isaac.FindByType(3, CustomFamiliars.ENRAGED_SOUL, 0, false, true)) do
			entity:Remove()
		end
		
		if player:HasTrinket(CustomTrinkets.ANGELS_CROWN) and roomtype == RoomType.ROOM_TREASURE 
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
		
		if player:HasTrinket(CustomTrinkets.PIECE_OF_CHALK) and not room:IsClear() and room:IsFirstVisit() then
			CustomData.CustomTrinkets.PIECE_OF_CHALK.RoomEnterFrame = game:GetFrameCount()
		end
		
		if player:HasCollectible(CustomCollectibles.TWO_PLUS_ONE) and CustomData then
			CustomData.Items.TWO_PLUS_ONE.ItemsBought_HEARTS = 0
			if CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS == 0 then
				for _, pickup in pairs(Isaac.FindByType(5, -1, -1, false, false)) do
					if pickup:ToPickup().Price == 1 then
						pickup:ToPickup().AutoUpdatePrice = true
					end
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.GUSTY_BLOOD) then
			CustomData.Items.GUSTY_BLOOD.CurrentTears = 0
			CustomData.Items.GUSTY_BLOOD.CurrentSpeed = 0
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
		end
		
		if player:GetData()['usedLoadedDice'] then
			player:GetData()['usedLoadedDice'] = false
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
		
		if player:HasCollectible(CustomCollectibles.TANK_BOYS) then
			for _, tank in pairs(Isaac.FindByType(3, CustomFamiliars.TOY_TANK_1, 0, false, true)) do tank:GetData().Data.newRoomCurrHold = game:GetFrameCount() end
			for _, tank in pairs(Isaac.FindByType(3, CustomFamiliars.TOY_TANK_2, 0, false, true)) do tank:GetData().Data.newRoomCurrHold = game:GetFrameCount() end
		end
		
		if player:HasCollectible(CustomCollectibles.CAT_IN_A_BOX) and not room:IsClear() then
			CustomData.Items.CAT_IN_A_BOX.RoomEnterFrame = game:GetFrameCount()
			for _, enemy in pairs(Isaac.GetRoomEntities()) do
				if enemy:IsVulnerableEnemy() and not enemy:IsBoss() then 
					enemy:TakeDamage(math.ceil(enemy.MaxHitPoints / 2), 1, EntityRef(player), 0) 
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.KEEPERS_PENNY) and room:GetType() == RoomType.ROOM_SHOP 
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
		
		if player:HasTrinket(CustomTrinkets.TORN_PAGE) then
			if player:GetData()['enhancedBoB'] then				
				player:GetData()['enhancedBoB'] = false
				player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
				player:EvaluateItems()
			end		
		end
	
		if player:GetData()['usedDemonForm'] 
		and not room:IsClear() and room:IsFirstVisit() then
			CustomData.Cards.DEMON_FORM.NumUses = CustomData.Cards.DEMON_FORM.NumUses + 1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
		
		if CustomData then
			CustomData.Items.RED_KING.IsInRedKingRoom = false
			if CustomData.Items.RED_KING.DescendedRedCrawlspace then
				CustomData.Items.RED_KING.IsInRedKingRoom = true
				CustomData.Items.RED_KING.DescendedRedCrawlspace = false
			end
			if CustomData.Items.RED_KING.DefeatedRedKingBoss then
				for _, redTrapdoor in pairs(Isaac.FindByType(6, 334, -1, false, false)) do
					redTrapdoor:GetSprite():Play("Closed")
					redTrapdoor.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				end
			end
		end
		
		if player:GetData().RejectionUsed == false then
			player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			player:EvaluateItems()
		end
		
		BLACKCHEST_SPAWN_CHANCE = BLACKCHEST_SPAWN_CHANCE + player:GetTrinketMultiplier(CustomTrinkets.KEY_KNIFE)
	end
	
	if room:GetType() == RoomType.ROOM_LIBRARY
	and room:IsFirstVisit() then
		RNGobj:SetSeed(Random() + 1, 1)
		local pageSpawnRoll = math.ceil(RNGobj:RandomFloat() * 100)
		
		if pageSpawnRoll < 33 and not CustomData.CustomTrinkets.TORN_PAGE.trinketSeen then
			Isaac.Spawn(5, 350, CustomTrinkets.TORN_PAGE, Isaac.GetFreeNearPosition(Vector(320, 280), 10), Vector.Zero, nil)
			CustomData.CustomTrinkets.TORN_PAGE.trinketSeen = true
		elseif pageSpawnRoll < 66 and not CustomData.CustomTrinkets.EMPTY_PAGE.trinketSeen then
			Isaac.Spawn(5, 350, CustomTrinkets.EMPTY_PAGE, Isaac.GetFreeNearPosition(Vector(320, 280), 10), Vector.Zero, nil)
			CustomData.CustomTrinkets.EMPTY_PAGE.trinketSeen = true
		end
	end
	
	if room:GetType() == RoomType.ROOM_PLANETARIUM
	and room:IsFirstVisit() and math.random(100) < STARGAZER_SPAWN_CHANCE["Planetarium"] then
		Isaac.Spawn(6, CustomPickups.SLOT_STARGAZER, 0, Isaac.GetFreeNearPosition(Vector(200, 240), 10), Vector.Zero, nil)
	end
	if room:GetType() == RoomType.ROOM_ARCADE and room:IsFirstVisit() then
		for _, beggar in pairs(Isaac.FindByType(6, -1, -1, false, false)) do
			if (beggar.Variant == 9 or beggar.Variant == 7 or beggar.Variant == 4 or beggar.Variant == 5 or beggar.Variant == 13)
			and math.random(100) < STARGAZER_SPAWN_CHANCE["Arcade"] then
				beggar:Remove()
				Isaac.Spawn(6, CustomPickups.SLOT_STARGAZER, 0, beggar.Position, Vector.Zero, nil)
				break
			end
		end
	end
	
	if room:GetType() == RoomType.ROOM_DEVIL
	and room:IsFirstVisit()	and #Isaac.FindByType(EntityType.ENTITY_FALLEN, 1, 0, false, true) == 0
	and math.random(100) < BLACKCHEST_SPAWN_CHANCE then
		Isaac.Spawn(5, CustomPickups.BLACK_CHEST, 0, Isaac.GetFreeNearPosition(Vector(440, 240), 10), Vector.Zero, nil)
		Isaac.Spawn(5, CustomPickups.BLACK_CHEST, 0, Isaac.GetFreeNearPosition(Vector(200, 240), 10), Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
		BLACKCHEST_SPAWN_CHANCE = 17
	end
	
	-- bloody rocks
	if level:GetStage() ~= LevelStage.STAGE7 then
		-- setting the variant
		for ind = 1, room:GetGridSize() do
			local gridEnt = room:GetGridEntity(ind)
			
			if gridEnt and gridEnt:GetType() == GridEntityType.GRID_ROCK_SPIKED then				
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomFloat() * 100
				
				if roll < BLOODYROCKS_REPLACE_CHANCE and room:IsFirstVisit()
				and CustomData and CustomData.NumTaintedRocks < 2 then
					gridEnt:SetVariant(2)
					CustomData.NumTaintedRocks = CustomData.NumTaintedRocks + 1
				end
			end
		end
		
		-- replacing the spritesheet
		for ind = 1, room:GetGridSize() do
			local gridEnt = room:GetGridEntity(ind)
			
			if gridEnt and gridEnt:GetType() == GridEntityType.GRID_ROCK_SPIKED and gridEnt:GetVariant() == 2 then				
				replaceBloodyRockSprite(gridEnt, room, level)
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, rplus.OnNewRoom)

						-- MC_POST_UPDATE --											
						--------------------
function rplus:PostUpdate()
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
		blacklistCollectibles(player, CustomCollectibles.RED_BOMBER, CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR)
		
		-- some differently colored pills have same effects with PHD/False PHD, and since the MC_USE_PILL asks for pill effect, there's no way to distinguish
		-- them and apply the DNA redactor effect correctly
		blacklistCollectibles(player, CustomCollectibles.DNA_REDACTOR, {CollectibleType.COLLECTIBLE_PHD, CollectibleType.COLLECTIBLE_FALSE_PHD})
		
		-- Mom's Knife and Spirit Sword have like... no difference in code, so while we added Knife synergy, Sword looks severely hurt from that
		-- plus we don't have the Sword resprite for a synergy
		blacklistCollectibles(player, CustomCollectibles.CEREMONIAL_BLADE, CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
		-----------------------------------------
		
		-- helper for telling ID of the sound that I want (I'm fucking tired)
		--for i = 1, 817 do
		--	if sfx:IsPlaying(i) then print(i) end
		--end
		
		if player:GetData()['reverseCardRoom'] and player:GetData()['reverseCardRoom'] ~= game:GetLevel():GetCurrentRoomIndex() then
			player:AnimateCard(CustomConsumables.UNO_REVERSE_CARD, "Pickup")
			local secondaryCard = player:GetCard(1)
			player:SetCard(1, 0)
			player:SetCard(0, secondaryCard)
			player:GetData()['reverseCardRoom'] = nil
		end
		
		if player:HasCollectible(CustomCollectibles.MAGIC_PEN) then
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
		
		if player:HasCollectible(CustomCollectibles.MARK_OF_CAIN) 
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
					player:RemoveCollectible(CustomCollectibles.MARK_OF_CAIN)
					for i = 0, game:GetNumPlayers() - 1 do
						Isaac.GetPlayer(i):Revive()
						GiveRevivalIVFrames(Isaac.GetPlayer(i))
					end
					
					CustomData.Items.MARK_OF_CAIN = "player revived"
					sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, 1, 0)
					
					for i = 1, #MyFamiliars do player:RemoveCollectible(MyFamiliars[i]) end
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
					player:EvaluateItems()
				end
			end
		end
		
		if CustomData and CustomData.Items.TEMPER_TANTRUM.SuperBerserkState and sfx:IsPlaying(SoundEffect.SOUND_BERSERK_END) then 
			CustomData.Items.TEMPER_TANTRUM.SuperBerserkState = false
		end
		if CustomData and CustomData.Items.TEMPER_TANTRUM.ErasedEnemies then
			for _, entity in pairs(Isaac.FindInRadius(Vector(320, 280), 1000, EntityPartition.ENEMY)) do
				for i = 1, #CustomData.Items.TEMPER_TANTRUM.ErasedEnemies do
					if entity.Type == CustomData.Items.TEMPER_TANTRUM.ErasedEnemies[i] then
						Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
						entity:Remove()
					end
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.CHERRY_FRIENDS) and room:IsClear() then
			for _, cherry in pairs(Isaac.FindByType(3, CustomFamiliars.CHERRY, -1, true, false)) do
				cherry:GetSprite():Play("Collect")
				if cherry:GetSprite():IsFinished("Collect") then
					cherry:Remove()
					Isaac.Spawn(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, cherry.Position, Vector.Zero, nil)
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.BIRD_OF_HOPE) then
			if isPlayerDying(player)
			and CustomData.Items.BIRD_OF_HOPE.BirdCaught == true then
				CustomData.Items.BIRD_OF_HOPE.BirdCaught = false
				DieFrame = game:GetFrameCount()
				DiePos = player.Position
				CustomData.Items.BIRD_OF_HOPE.NumRevivals = CustomData.Items.BIRD_OF_HOPE.NumRevivals + 1
				
				player:GetData()['catchingBird'] = true
				player:Revive()
				sprite:Stop()
				player:AddCacheFlags(CacheFlag.CACHE_FLYING)
				player:EvaluateItems()
				player:AddNullCostume(Costumes.BIRD_OF_HOPE)
				
				Birdy = Isaac.Spawn(3, CustomFamiliars.BIRD, 0, room:GetCenterPos(), Vector.FromAngle(math.random(360)) * CustomData.Items.BIRD_OF_HOPE.NumRevivals, nil) 
				Birdy:GetSprite():Play("Flying")
			elseif DieFrame and game:GetFrameCount() > DieFrame + 120 and not CustomData.Items.BIRD_OF_HOPE.BirdCaught then
				player:Die()
				CustomData.Items.BIRD_OF_HOPE.BirdCaught = "blah blah"	-- just so that it's not true and player doesn't die over and over 
				-- until all his extra lives are depleted
				-- !!! THIS IS A SERIOUS CROTCH !!! since you end up near the door when reviving, and the bird familiar doesn't despawn if you don't catch her,
				-- you automatically pick her up and this allows you to repeat the cycle (since it switches data to true) and doesn't take away your extra lives
				-- so don't touch it if you don't think it through. like, for real.
			end
		end
		
		if player:HasTrinket(CustomTrinkets.PIECE_OF_CHALK) and CustomData then
			if CustomData.CustomTrinkets.PIECE_OF_CHALK.RoomEnterFrame 
			and game:GetFrameCount() <= CustomData.CustomTrinkets.PIECE_OF_CHALK.RoomEnterFrame + 150 
			and game:GetFrameCount() % 2 == 0 then
				local Powder = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 5, player.Position, Vector.Zero, nil):ToEffect()
				
				Powder:GetSprite():Load("gfx/1000.333_effect_chalk_powder.anm2", true)
				Powder.Timeout = 600
				Powder:SetColor(Color(1, 1, 1, 1, 0, 0, 0), 610, 1, true, false)
				Powder:Update()
			end
		end
		
		if CustomData and CustomData.Cards.SACRIFICIAL_BLOOD.Data then
			if game:GetFrameCount() % math.floor(1 + 11 / CustomData.Cards.SACRIFICIAL_BLOOD.NumUses) == 0 then
				Step = Step + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
				if Step == 50 * CustomData.Cards.SACRIFICIAL_BLOOD.NumUses then 
					CustomData.Cards.SACRIFICIAL_BLOOD.Data = false 
					CustomData.Cards.SACRIFICIAL_BLOOD.NumUses = 0
				end
			end
		end
		
		if player:HasTrinket(CustomTrinkets.ADAMS_RIB) then
			if isPlayerDying(player) then
				player:TryRemoveTrinket(CustomTrinkets.ADAMS_RIB)
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
		
		if player:HasCollectible(CustomCollectibles.TWO_PLUS_ONE) then
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 then
					EntPickup = entity:ToPickup()
					if EntPickup.Price > 0 and CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS == 2  then
						EntPickup.Price = 1
						EntPickup.AutoUpdatePrice = false
					elseif EntPickup.Price > -1000 and EntPickup.Price < 0 and CustomData.Items.TWO_PLUS_ONE.ItemsBought_HEARTS == 2  then
						EntPickup.Price = 0
					end
				end
			end
		end
		
		if CustomData and CustomData.CustomPills.LAXATIVE.UseFrame and game:GetFrameCount() % 4 == 0 then
			if (game:GetFrameCount() <= CustomData.CustomPills.LAXATIVE.UseFrame + 90 and player:GetData()['usedLax'])
			or (game:GetFrameCount() <= CustomData.CustomPills.LAXATIVE.UseFrame + 360 and player:GetData()['usedHorseLax']) then
				local vector = Vector.FromAngle(DIRECTION_VECTOR[player:GetMovementDirection()]:GetAngleDegrees() + math.random(-15, 15)):Resized(-7.5)
				local SCorn = Isaac.Spawn(2, 0, 0, player.Position, vector, nil):GetSprite()
				
				SCorn:Load("gfx/002.122_corn_tear.anm2", true)
				SCorn:Play("Big0" .. math.random(4))
				cornScale = math.random(5, 10) / 10
				SCorn.Scale = Vector(cornScale, cornScale)
			else
				CustomData.CustomPills.LAXATIVE.UseFrame = nil
				player:GetData()['usedLax'] = false
				player:GetData()['usedHorseLax'] = false
			end
		end
		
		if player:HasCollectible(CustomCollectibles.RED_MAP) and not room:IsFirstVisit() 
		and room:GetType() < 6 and room:GetType() > 3 then
			for _, trinket in pairs(Isaac.FindByType(5, 350, -1, false, false)) do
				trinket:ToPickup():Morph(5, 300, Card.CARD_CRACKED_KEY, true, true, true)
			end
		end
		
		if CustomData and CustomData.CustomPills.PHANTOM_PAINS.UseFrame and (game:GetFrameCount() - CustomData.CustomPills.PHANTOM_PAINS.UseFrame) % 600 == 1 then
			if game:GetFrameCount() <= CustomData.CustomPills.PHANTOM_PAINS.UseFrame + 1300 
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
		
		if player:HasCollectible(CustomCollectibles.CAT_IN_A_BOX) and CustomData.Items.CAT_IN_A_BOX.RoomEnterFrame
		and game:GetFrameCount() == CustomData.Items.CAT_IN_A_BOX.RoomEnterFrame + 90 then
			for _, enemy in pairs(Isaac.FindInRadius(player.Position, 800, EntityPartition.ENEMY)) do
				if not enemy:IsBoss() then 
					enemy:AddHealth(enemy.MaxHitPoints)
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			if CustomData.Items.MOTHERS_LOVE.NumFriends ~= #Isaac.FindByType(3, -1, -1, false, false) then
				CustomData.Items.MOTHERS_LOVE.NumStats = 0
				if #Isaac.FindByType(3, -1, -1, false, false) > 0 then
					for _, friend in pairs(Isaac.FindByType(3, -1, -1, false, false)) do
						LoveStatMulGiven = getMothersLoveStatBoost(friend.Variant)
						
						CustomData.Items.MOTHERS_LOVE.NumStats = CustomData.Items.MOTHERS_LOVE.NumStats + LoveStatMulGiven
					end
				end
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_RANGE)
				player:EvaluateItems()
				
				CustomData.Items.MOTHERS_LOVE.NumFriends = #Isaac.FindByType(3, -1, -1, false, false)
			end
		end
		
		if player:HasCollectible(CustomCollectibles.SCALPEL) and game:GetFrameCount() % 6 == 0 then
			for i = 4, 7 do -- shooting left, right, up, down
				if Input.IsActionPressed(i, player.ControllerIndex) then
					local RedTear = player:FireTear(player.Position + DIRECTION_VECTOR[player:GetFireDirection()]:Resized(25), Vector.FromAngle(DIRECTION_VECTOR[player:GetFireDirection()]:GetAngleDegrees() + math.random(-10, 10)):Resized(-8), false, true, false, player, 0.66)
					RedTear.FallingAcceleration = 0.8
					RedTear.FallingSpeed = -8
					if RedTear.Variant ~= TearVariant.BLOOD then RedTear:ChangeVariant(TearVariant.BLOOD) end
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.NERVE_PINCH) and CustomData.Items.NERVE_PINCH.Hold <= 0 then
			CustomData.Items.NERVE_PINCH.Hold = NERVEPINCH_HOLD
			player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 30)
			CustomData.Items.NERVE_PINCH.NumTriggers = CustomData.Items.NERVE_PINCH.NumTriggers + 1
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
			local primaryItem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
			
			if Isaac.GetItemConfig():GetCollectible(primaryItem).MaxCharges > 0
			and not (primaryItem == 490 or primaryItem == 585)
			and math.random(100) <= NERVEPINCH_USE_CHANCE then
				player:UseActiveItem(primaryItem, 0, -1)
			end
		end
		
		-- Sibling Rivalry changing forms every 15 seconds (it works flawlessly now!!!)
		if getTrueFamiliarNum(player, CustomCollectibles.SIBLING_RIVALRY) > 0 
		and game:GetFrameCount() % SIBLING_STATE_SWITCH_COOLDOWN == 0 then
			local d = player:GetData()['fightingSiblings']
			if d == false or type(d) == 'nil' then 
				d = true 
				sfx:Play(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1, 2, false, 1, 0)
			else 
				d = false 
			end
			player:GetData()['fightingSiblings'] = d
			for _, s in pairs(Isaac.FindByType(3, -1, -1, false, true)) do 
				if s.Variant == CustomFamiliars.SIBLING_1 or 
				s.Variant == CustomFamiliars.SIBLING_2 or
				s.Variant == CustomFamiliars.FIGHTING_SIBLINGS then
					s:Remove()
				end
			end
			
			player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			player:EvaluateItems()
		end
		
		if player:HasTrinket(CustomTrinkets.TORN_PAGE) and player:HasCollectible(CollectibleType.COLLECTIBLE_HOW_TO_JUMP)
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
		
		if player:HasCollectible(CustomCollectibles.RED_KING) and room:GetType() == RoomType.ROOM_BOSS and stage < 9
		and math.abs(player.Position.X - 320) < 20 and math.abs(player.Position.Y - 280) < 20 
		and #Isaac.FindByType(6, 334, -1, false, false) > 0 
		and not CustomData.Items.RED_KING.IsInRedKingRoom and not CustomData.Items.RED_KING.DefeatedRedKingBoss then
			Isaac.ExecuteCommand("goto s.boss." .. tostring(REDKING_BOOSROOM_IDS[math.random(#REDKING_BOOSROOM_IDS)]))
			CustomData.Items.RED_KING.DescendedRedCrawlspace = true
		end
		
		if player:GetData()['BagUsed'] then
			if game:GetFrameCount() < CustomData.Items.BOTTOMLESS_BAG.UseFrame + 120 then
				for _, entity in pairs(Isaac.FindInRadius(player.Position, 40, EntityPartition.PROJECTILE)) do
					if entity:ToProjectile() then
						entity:Remove()     
						CustomData.Items.BOTTOMLESS_BAG.TearCount = CustomData.Items.BOTTOMLESS_BAG.TearCount + 1
					end
				end
				
				if game:GetFrameCount() < CustomData.Items.BOTTOMLESS_BAG.UseFrame + 100 then
					for _, entity in pairs(Isaac.FindInRadius(player.Position, 300, EntityPartition.PROJECTILE)) do
						if entity:ToProjectile() then
							entity:AddVelocity((player.Position - entity.Position):Normalized())   
						end
					end
				elseif game:GetFrameCount() == CustomData.Items.BOTTOMLESS_BAG.UseFrame + 100 then
					player:AnimateCollectible(CustomCollectibles.BOTTOMLESS_BAG, "HideItem", "PlayerPickupSparkle")
					if CustomData.Items.BOTTOMLESS_BAG.TearCount > 1 then
						GiveRevivalIVFrames(player)
						local shootVector = DIRECTION_VECTOR[player:GetFireDirection()]
						
						for i = 1, CustomData.Items.BOTTOMLESS_BAG.TearCount do
							extraOffset = Vector(math.random(-5,5), math.random(-5,5))
							local vacuumTear = player:FireTear(player.Position, shootVector * math.random(6, 15) + extraOffset, false, true, false, player)
							vacuumTear.TearFlags = vacuumTear.TearFlags | TearFlags.TEAR_HOMING 
							local color = Color(1, 1, 1, 1, 0, 0, 0)
							color:SetColorize(1, 0, 1, 1)
							vacuumTear:SetColor(color, 0, 0, true, false)
						end
					end
				end
			else
				CustomData.Items.BOTTOMLESS_BAG.TearCount = 0
				CustomData.Items.BOTTOMLESS_BAG.UseFrame = 0
				player:GetData()['BagUsed'] = false
			end
		end
		
		if player:HasCollectible(CustomCollectibles.CROSS_OF_CHAOS) then
			for _, enemy in pairs(Isaac.FindInRadius(player.Position, 50, EntityPartition.ENEMY)) do
				local d = enemy:GetData()
				if not d.IsCrippled and enemy:IsVulnerableEnemy() and not enemy:IsBoss() then
					-- applying custom debuffs to enemies
					d.IsCrippled = true
					d.CrippleStartFrame = game:GetFrameCount()
					d.CrippleDeathBurst = false
					local crippleHands = Isaac.Spawn(1000, CripplingHandsHelper, 0, enemy.Position + Vector(0, 5), Vector.Zero, enemy):ToEffect()
					crippleHands:GetSprite():Play("ClawsAppearing")
				end
			end
		end	
		
		if player:HasCollectible(CustomCollectibles.ANGELS_WINGS) then -- brimstone costume for angel's wings 
		 	for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == EntityType.ENTITY_LASER and entity.Variant == 1 and entity.Parent.Type == 1 then
					local laserSprite = entity:GetSprite()
					laserSprite:ReplaceSpritesheet(0, "gfx/static_laser.png")
					laserSprite:LoadGraphics()
				end
			end
		end 
		
		-- balancing the amount of active (main) and passive (technical) Rejection items
		if player:GetCollectibleNum(CustomCollectibles.REJECTION) > player:GetCollectibleNum(CustomCollectibles.REJECTION_P) then
			player:AddCollectible(CustomCollectibles.REJECTION_P)
		elseif player:GetCollectibleNum(CustomCollectibles.REJECTION) < player:GetCollectibleNum(CustomCollectibles.REJECTION_P) then
			player:RemoveCollectible(CustomCollectibles.REJECTION_P)
		end
	end
	
	-- black chests
	for _, bc in pairs(Isaac.FindByType(5, CustomPickups.BLACK_CHEST, 2, false, false)) do
		if bc:GetData()['OpenFrame'] and game:GetFrameCount() >= bc:GetData()['OpenFrame'] + 60 then
			local bcSprite = bc:GetSprite()
			
			bcSprite:Play("Close")
			sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			bc.SubType = 0
		end
	end
	
	-- stargazer
	for _, sg in pairs(Isaac.FindByType(6, CustomPickups.SLOT_STARGAZER, -1, false, false)) do
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
			Isaac.Spawn(5, 100, CustomItempools.STARGAZER[math.random(#CustomItempools.STARGAZER)], Isaac.GetFreeNearPosition(Vector(sg.Position.X, sg.Position.Y + 40), 40), Vector.Zero, nil)
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
			
			for i, v in pairs(DropTables.BLOODYROCKS) do
				if roll < DropTables.BLOODYROCKS[i][1] then
					for x, y in pairs(DropTables.BLOODYROCKS[i][2]) do
						Isaac.Spawn(5, y[1], y[2], gridEnt.Position, Vector.FromAngle(math.random(360)) * 3, Pickup)
					end
					break
				end
			end
			
			gridEnt.VarData = 1
		end
	end
	
	-- cripple hands
	for _, obj in pairs(Isaac.FindByType(1000, CripplingHandsHelper, 0, true, false)) do
		if obj:GetSprite():IsFinished("ClawsAppearing") then obj:GetSprite():Play("ClawsHolding") end
		if not obj.SpawnerEntity then obj:Remove()
		else obj.Position = obj.SpawnerEntity.Position + Vector(0, 5) end
	end	

	-- Soul Bond
	for _, enemy in pairs(Isaac.FindInRadius(Vector(320, 280), 800, EntityPartition.ENEMY)) do
		-- enemies colliding with Soul Bond chains
		if isCollidingWithAstralChain(enemy) and game:GetFrameCount() % 3 == 0 then
			enemy:TakeDamage(0.75, 0, EntityRef(enemy), 0)
		end
	end
	for _, chain in pairs(Isaac.FindByType(865, 10, 1, true, false)) do
		-- removing the chain if the target is dead; chained enemies have a 50% chance to drop half a soul heart when killed
		if not chain.Target or chain.Target:IsDead() then 
			chain:Remove()
			if math.random() < 0.5 then Isaac.Spawn(5, 10, HeartSubType.HEART_HALF_SOUL, chain.Target.Position, Vector.Zero, nil) end
		-- breaking the chain if you get too far away from enemy
		elseif math.abs((chain.Parent.Position - chain.Target.Position):Length()) > 325 then
			chain:Remove()
			chain.Target:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
			sfx:Play(SoundEffect.SOUND_ANIMA_BREAK, 1, 2, false, 1, 0)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_UPDATE, rplus.PostUpdate)

						-- MC_USE_ITEM --										
						-----------------
function rplus:OnItemUse(ItemUsed, _, Player, _, Slot, _)
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	if ItemUsed == CustomCollectibles.COOKIE_CUTTER then
		Player:AddMaxHearts(2, true)
		Player:AddBrokenHearts(1)
		sfx:Play(SoundEffect.SOUND_BLOODBANK_SPAWN, 1, 2, false, 1, 0)
		if Player:GetBrokenHearts() >= 12 then
			Player:Die()
		end
		return true
	end
	
	if ItemUsed == CustomCollectibles.CHEESE_GRATER and Player:GetMaxHearts() > 0 then
		Player:AddMaxHearts(-2, false)
		Player:AddMinisaac(Player.Position, true)
		Player:AddMinisaac(Player.Position, true)
		Player:AddMinisaac(Player.Position, true)
		sfx:Play(SoundEffect.SOUND_BLOODBANK_SPAWN, 1, 2, false, 1, 0)
		Player:GetData()['graterUsed'] = true
		
		CustomData.Items.CHEESE_GRATER.NumUses = CustomData.Items.CHEESE_GRATER.NumUses + 1
		Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		Player:EvaluateItems()
	end
	
	if ItemUsed == CustomCollectibles.RUBIKS_CUBR then
		RNGobj:SetSeed(Random() + 1, 1)
		local solveChance = RNGobj:RandomInt(100) + 1
		
		if solveChance <= 5 or CustomData.Items.RUBIKS_CUBR.Counter == 20 then
			Player:RemoveCollectible(CustomCollectibles.RUBIKS_CUBR, true, ActiveSlot.SLOT_PRIMARY, true)
			Player:AddCollectible(CustomCollectibles.MAGIC_CUBE, 4, true, ActiveSlot.SLOT_PRIMARY, 0)
			Player:AnimateHappy()
			CustomData.Items.RUBIKS_CUBR.Counter = 0
			return false
		else
			CustomData.Items.RUBIKS_CUBR.Counter = CustomData.Items.RUBIKS_CUBR.Counter + 1
			return true
		end
	end
	
	if ItemUsed == CustomCollectibles.MAGIC_CUBE then
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 5 and entity.Variant == 100 and entity.SubType > 0 then
				entity:ToPickup():Morph(5, 100, GetUnlockedVanillaCollectible(true), true, false, true)
			end
		end
		return true
	end
	
	if ItemUsed == CustomCollectibles.QUASAR then
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
	
	if ItemUsed == CustomCollectibles.TOWER_OF_BABEL then
		for g = 1, room:GetGridSize() do
			if room:GetGridEntity(g) then room:GetGridEntity(g):Destroy() end
		end
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 200, EntityPartition.ENEMY)) do
			if not enemy:IsBoss() then enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION) end
		end
		return {Discharge = true, Remove = false, ShowAnim = true}
	end
	
	if ItemUsed == CustomCollectibles.BOOK_OF_GENESIS then 
		local freezePreventChecker = 0
		CustomData.Items.BOOK_OF_GENESIS.Index = CustomData.Items.BOOK_OF_GENESIS.Index + 1
		
		repeat
			ID = Player:GetDropRNG():RandomInt(Isaac.GetItemConfig():GetCollectibles().Size - 1) + 1
			freezePreventChecker = freezePreventChecker + 1
		until (Player:HasCollectible(ID, true)
		and Isaac.GetItemConfig():GetCollectible(ID).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
		and Isaac.GetItemConfig():GetCollectible(ID).Type % 3 == 1)
		or freezePreventChecker == 10000
		
		if freezePreventChecker < 10000 then
			Player:AnimateCollectible(ID, "UseItem", "PlayerPickupSparkle")
			Player:RemoveCollectible(ID, true, -1, true)
		
			local Q = Isaac.GetItemConfig():GetCollectible(ID).Quality
			for i = 1, (Player:HasTrinket(CustomTrinkets.TORN_PAGE) and 4 or 3) do
				repeat 
					newID = GetUnlockedVanillaCollectible(true)
				until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1 and Isaac.GetItemConfig():GetCollectible(newID).Quality == Q
				and Isaac.GetItemConfig():GetCollectible(newID).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
				
				local bookOfGenesisItem = Isaac.Spawn(5, 100, newID, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil):ToPickup()
				bookOfGenesisItem.OptionsPickupIndex = CustomData.Items.BOOK_OF_GENESIS.Index
			end
			sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 2, false, 1, 0)
			return {Discharge = true, Remove = false, ShowAnim = false}
		else 
			return {Discharge = false, Remove = false, ShowAnim = false}
		end
	end
	
	for i = 1, #CustomCollectibles.BLOOD_VESSELS do
		if ItemUsed == CustomCollectibles.BLOOD_VESSELS[i] then
			if i == 7 and Player:GetDamageCooldown() <= 0 then
				CustomData.Items.BLOODVESSEL.DamageFlag = true
				Player:TakeDamage(6, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(Player), 18)
				Player:RemoveCollectible(CustomCollectibles.BLOOD_VESSELS[7])
				Player:AddCollectible(CustomCollectibles.BLOOD_VESSELS[1])
				CustomData.Items.BLOODVESSEL.DamageFlag = false
			else
				return false
			end
		end
	end
	
	if Player:HasTrinket(CustomTrinkets.TORN_PAGE) then
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
		-- monster manual spawns weaker CustomFamiliars when used (dips, flies and spiders)
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
	
	if Player:HasTrinket(CustomTrinkets.EMPTY_PAGE) then
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
		or ItemUsed == CustomCollectibles.BOOK_OF_GENESIS
		then
			Player:UseActiveItem(CustomItempools.EMPTYPAGEACTIVES[math.random(#CustomItempools.EMPTYPAGEACTIVES)], UseFlag.USE_NOANIM, -1)
		end
	end
	
	if ItemUsed == CustomCollectibles.STARGAZERS_HAT then
		Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
		sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 2, false, 1, 0)
		Isaac.Spawn(6, CustomPickups.SLOT_STARGAZER, 0, Isaac.GetFreeNearPosition(Player.Position, 40), Vector.Zero, nil)
	end
	
	if ItemUsed == CustomCollectibles.BOTTOMLESS_BAG then 
		Player:GetData()['BagUsed'] = true
		CustomData.Items.BOTTOMLESS_BAG.UseFrame = game:GetFrameCount()
		CustomData.Items.BOTTOMLESS_BAG.Data = true
		Player:AnimateCollectible(CustomCollectibles.BOTTOMLESS_BAG, "LiftItem", "PlayerPickupSparkle")
	end
	
	if ItemUsed == CustomCollectibles.REJECTION then
		Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
		Player:GetData().FamiliarsInBelly = {}
		
		for _, lil in pairs(Isaac.FindByType(3, -1, -1, false, true)) do
			if lil:ToFamiliar() and lil:ToFamiliar().IsFollower then
				table.insert(Player:GetData().FamiliarsInBelly, lil.Variant)
				lil:Remove()
			end
		end
		
		if #Player:GetData().FamiliarsInBelly > 0 then
			Player:GetData().RejectionUsed = true -- for repeatedly deleting CustomFamiliars afterwards
			sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 2, false, 1, 0)
		end
	end
	
	if ItemUsed == CustomCollectibles.AUCTION_GAVEL then
		Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
		sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 2, false, 1, 0)
		local auctionCollectible = Isaac.Spawn(5, 100, GetUnlockedVanillaCollectible(false), Isaac.GetFreeNearPosition(Player.Position, 40), Vector.Zero, Player):ToPickup()
		auctionCollectible.AutoUpdatePrice = false
		auctionCollectible.Price = 15
		auctionCollectible.ShopItemId = -321
		auctionCollectible:GetData().Data = true
	end
	
	if ItemUsed == CustomCollectibles.SOUL_BOND then
		local en = {}
		for _, ent in pairs(Isaac.FindInRadius(Player.Position, 275, EntityPartition.ENEMY)) do
			if ent:IsVulnerableEnemy() and not ent:IsBoss() then table.insert(en, ent) end
		end
		
		if #en > 0 then
			local astralChain = Isaac.Spawn(865, 10, 1, Player.Position, Vector.Zero, Player)
			astralChain:GetSprite():ReplaceSpritesheet(0, "gfx/astral_chain.png")
			astralChain:GetSprite():ReplaceSpritesheet(1, "gfx/astral_chain.png")
			astralChain:GetSprite():LoadGraphics()
			sfx:Play(SoundEffect.SOUND_ANIMA_TRAP, 1, 2, false, 1, 0)
			astralChain.Parent = Player
			astralChain.Target = en[math.random(#en)]
			astralChain.Target:AddEntityFlags(EntityFlag.FLAG_FREEZE)
			astralChain.Target:GetData()['isChainedToPlayer'] = true
			
			return {Discharge = true, Remove = false, ShowAnim = true}
		else
			return {Discharge = false, Remove = false, ShowAnim = false}
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_ITEM, rplus.OnItemUse)


						-- MC_USE_CARD -- 										
						-----------------
function rplus:CardUsed(CardUsed, Player, _)	
	local room = game:GetRoom()
	
	if CardUsed == CustomConsumables.JOKER_Q then
		game:StartRoomTransition(-6, -1, RoomTransitionAnim.TELEPORT, Player, -1)
	end
	
	if CardUsed == CustomConsumables.SPINDOWN_DICE_SHARD then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_SPINDOWN_DICE, UseFlag.USE_NOANIM, -1)
	end
	
	if CardUsed == CustomConsumables.BUSINESS_CARD then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_FRIEND_FINDER, UseFlag.USE_NOANIM, -1)
	end
	
	if CardUsed == CustomConsumables.RED_RUNE then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_ABYSS, false, false, true, false, -1)
		for _, entity in pairs(Isaac.FindInRadius(Player.Position, 1000, EntityPartition.ENEMY)) do
			entity:TakeDamage(40, 0, EntityRef(Player), 0)
		end
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
	
	if CardUsed == CustomConsumables.UNO_REVERSE_CARD then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false, false, true, false, -1)
		Player:GetData()["reverseCardRoom"] = game:GetLevel():GetCurrentRoomIndex()
	end
	
	if CardUsed == CustomConsumables.KING_OF_SPADES then
		sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 2, false, 1, 0)
		local NumPickups = math.min(math.floor(Player:GetNumKeys() / 3), 11)
		Player:AddKeys(-math.min(Player:GetNumKeys(), 33))
		if Player:HasGoldenKey() then Player:RemoveGoldenKey() NumPickups = NumPickups + 2 end
		for i = 1, NumPickups do
			--Player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, false, false, true, false, -1)
			--Player:GetData().NoEmptyPageTrigger = true
			room:SpawnClearAward()
		end
		if NumPickups >= 3 then Isaac.Spawn(5, 350, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
		if NumPickups >= 7 then Isaac.Spawn(5, 100, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
	end
	
	if CardUsed == CustomConsumables.KING_OF_CLUBS then
		local NumPickups = math.min(math.floor(Player:GetNumBombs() / 3), 11)
		Player:AddBombs(-math.min(Player:GetNumBombs(), 33))
		if Player:HasGoldenBomb() then Player:RemoveGoldenBomb() NumPickups = NumPickups + 2 end
		for i = 1, NumPickups do
			--Player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, false, false, true, false, -1)
			--Player:GetData().NoEmptyPageTrigger = true
			room:SpawnClearAward()
		end
		if NumPickups >= 3 then Isaac.Spawn(5, 350, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
		if NumPickups >= 7 then Isaac.Spawn(5, 100, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
	end
	
	if CardUsed == CustomConsumables.KING_OF_DIAMONDS then
		local NumPickups = math.min(math.floor(Player:GetNumCoins() / 6), 11)
		Player:AddCoins(-math.min(Player:GetNumCoins(), 66))
		for i = 1, NumPickups do
			--Player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SIN, false, false, true, false, -1)
			--Player:GetData().NoEmptyPageTrigger = true
			room:SpawnClearAward()
		end
		if NumPickups >= 4 then Isaac.Spawn(5, 350, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
		if NumPickups >= 9 then Isaac.Spawn(5, 100, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, nil) end
	end
	
	if CardUsed == CustomConsumables.NEEDLE_AND_THREAD then
		if Player:GetBrokenHearts() > 0 then
			Player:AddBrokenHearts(-1)
			Player:AddMaxHearts(2, true)
			Player:AddHearts(2)
		end
	end
	
	if CardUsed == CustomConsumables.QUEEN_OF_DIAMONDS then
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
	
	if CardUsed == CustomConsumables.QUEEN_OF_CLUBS then
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
	
	if CardUsed == CustomConsumables.BAG_TISSUE then
		local Weights = {}
		local SumWeight = 0
		local EnoughConsumables = true
		
		-- getting total weight of 8 most valuable CustomPickups in a room
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
	
	if CardUsed == CustomConsumables.LOADED_DICE then
		Player:GetData()['usedLoadedDice'] = true
		
		Player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		Player:EvaluateItems()
	end
	
	-- jacks
	if CardUsed == CustomConsumables.JACK_OF_DIAMONDS then
		CustomData.Cards.JACK = "Diamonds"
	elseif CardUsed == CustomConsumables.JACK_OF_CLUBS then
		CustomData.Cards.JACK = "Clubs"
	elseif CardUsed == CustomConsumables.JACK_OF_SPADES then
		CustomData.Cards.JACK = "Spades"	
	elseif CardUsed == CustomConsumables.JACK_OF_HEARTS then
		CustomData.Cards.JACK = "Hearts"
	end
	
	if CardUsed == CustomConsumables.BEDSIDE_QUEEN then		
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
	
	if CardUsed == CustomConsumables.QUASAR_SHARD then
		for _, entity in pairs(Isaac.FindInRadius(Player.Position, 1000, EntityPartition.ENEMY)) do
			entity:TakeDamage(40, 0, EntityRef(Player), 0)
		end
		
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
	
	if CardUsed == CustomConsumables.SACRIFICIAL_BLOOD and CustomData then
		CustomData.Cards.SACRIFICIAL_BLOOD.Data = true
		CustomData.Cards.SACRIFICIAL_BLOOD.NumUses = CustomData.Cards.SACRIFICIAL_BLOOD.NumUses + 1
		Step = 0
		Player:GetData()['usedBlood'] = true
		
		sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 2, false, 1, 0)
		if Player:HasCollectible(216) then Player:AddHearts(2) end		-- bonus for ceremonial robes ;)
	end
	
	if CardUsed == CustomConsumables.FLY_PAPER then
		for i = 1, 9 do
			Player:AddSwarmFlyOrbital(Player.Position)
		end
	end
	
	if CardUsed == CustomConsumables.LIBRARY_CARD then
		Player:UseActiveItem(game:GetItemPool():GetCollectible(ItemPoolType.POOL_LIBRARY, false, Random() + 1, 0), true, false, true, true, -1)
	end
	
	if CardUsed == CustomConsumables.FUNERAL_SERVICES then
		Isaac.Spawn(5, PickupVariant.PICKUP_OLDCHEST, 0, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil)
	end
	
	if CardUsed == CustomConsumables.MOMS_ID then
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 560, EntityPartition.ENEMY)) do
			if not enemy:IsBoss() then enemy:AddEntityFlags(EntityFlag.FLAG_CHARM) end
		end
	end
	
	if CardUsed == CustomConsumables.ANTIMATERIAL_CARD then
		local antimaterialCardTear = Isaac.Spawn(2, CustomTearVariants.ANTIMATERIAL_CARD, 0, Player.Position, DIRECTION_VECTOR[Player:GetMovementDirection()]:Resized(10), Player)
		antimaterialCardTear:GetSprite():Play("Rotate")
	end
	
	if CardUsed == CustomConsumables.DEMON_FORM and CustomData then
		Player:GetData()['usedDemonForm'] = true
	end
	
	if CardUsed == CustomConsumables.FIEND_FIRE then 
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
		for _, chest in pairs(Isaac.FindByType(5, CustomPickups.SCARLET_CHEST, -1, false, false)) do
			if chest.SubType == 0 or chest.SubType == 2 then
				openScarletChest(chest)
			end
		end
	end
	if CardUsed == CustomConsumables.MIRRORED_LANDSCAPE then
		local activeitem = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		local pocketitem = player:GetActiveItem(ActiveSlot.SLOT_POCKET)
		if pocketitem == 0 then
            		player:RemoveCollectible(activeitem)
            		player:SetPocketActiveItem(activeitem, ActiveSlot.SLOT_POCKET, false)
        	else 
            		Isaac.Spawn(5, 100, pocketitem, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil):ToPickup()
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
		
	if pillEffect == CustomPills.ESTROGEN then	-- no horse bonus effects
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
		local BloodClots = Player:GetHearts() - 2 
		
		Player:AddHearts(-BloodClots)
		for i = 1, BloodClots do
			Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, 0, Player.Position, Vector.Zero, nil)
		end
	end
	
	if pillEffect == CustomPills.LAXATIVE then
		if pillColor < 2048 then
			Player:GetData()['usedLax'] = true
		else
			Player:GetData()['usedHorseLax'] = true	-- increased duration for horse pill
		end
		CustomData.CustomPills.LAXATIVE.UseFrame = game:GetFrameCount()
		sfx:Play(SoundEffect.SOUND_FART, 1, 2, false, 1, 0)
		Player:AnimateSad()
	end
	
	if Player:HasCollectible(CustomCollectibles.DNA_REDACTOR) then
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
				CustomData.Items.TEMPER_TANTRUM.SuperBerserkState = true
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
			Player:RemoveCollectible(CustomCollectibles.DNA_REDACTOR)
		end
	end
	
	if pillEffect == CustomPills.PHANTOM_PAINS and CustomData
	and not isInGhostForm(Player) then
		if pillColor < 2048 then
			Player:GetData()['usedPhantom'] = true
		else
			Player:GetData()['usedHorsePhantom'] = true	-- taking fake damage will also cause to shoot 8 bone tears in all directions
		end
		CustomData.CustomPills.PHANTOM_PAINS.UseFrame = game:GetFrameCount()
	end
	
	if pillEffect == CustomPills.YUCK and CustomData then
		if pillColor < 2048 then
			Player:GetData()['usedYuck'] = true
		else
			Player:GetData()['usedHorseYuck'] = true	-- increased duration for horse pill
		end
		CustomData.CustomPills.YUCK.UseFrame = game:GetFrameCount()
		Isaac.Spawn(5, 10, 12, Player.Position, Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
	end
	
	if pillEffect == CustomPills.YUM and CustomData then
		if pillColor < 2048 then
			Player:GetData()['usedYum'] = true
		else
			Player:GetData()['usedHorseYum'] = true	-- increased duration for horse pill
		end
		CustomData.CustomPills.YUM.UseFrame = game:GetFrameCount()
		Isaac.Spawn(5, 10, 1, Player.Position, Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_PILL, rplus.usePill)

						-- MC_POST_PLAYER_UPDATE --									
						---------------------------
function rplus:PostPlayerUpdate(Player)
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	if Input.IsButtonTriggered(Keyboard.KEY_H, Player.ControllerIndex) and not hideErrorMessage then
		print('Error message hidden. To see it again, type *show* into the console')
		hideErrorMessage = true
	end	
	
	-- this callback handles inputs, because it rolls in 60 fps, unlike MC_POST_UPDATE, so inputs won't be missed out
	if Player:HasCollectible(CustomCollectibles.ENRAGED_SOUL) then
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
			(not CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown or CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown <= 0) then
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
				CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown = ENRAGED_SOUL_COOLDOWN
				local Soul = Isaac.Spawn(3, CustomFamiliars.ENRAGED_SOUL, 0, Player.Position, Velocity * 12, nil)
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
		
		if CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown then 
			CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown = CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown - 1
		end
	end
	
	if Player:GetSprite():IsPlaying("Appear") and Player:GetSprite():IsEventTriggered("FX") and level:GetCurses() ~= 0 
	and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= LevelCurse.CURSE_OF_LABYRINTH then
		if Player:HasTrinket(CustomTrinkets.NIGHT_SOIL) and math.random(100) < NIGHT_SOIL_CHANCE then
			level:RemoveCurses(level:GetCurses())
			game:GetHUD():ShowFortuneText("Night Soil protects you")
			Player:AnimateHappy()
		end
		
		if Player:HasCollectible(CustomCollectibles.BLESS_OF_THE_DEAD) then 
			CustomData.Items.BLESS_OF_THE_DEAD.NumUses = CustomData.Items.BLESS_OF_THE_DEAD.NumUses + 1
			game:GetHUD():ShowFortuneText("The Dead protect you")
			level:RemoveCurses(level:GetCurses())
			Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			Player:EvaluateItems()
		end
	end
	
	if Player:HasTrinket(CustomTrinkets.MAGIC_SWORD) or Player:HasTrinket(CustomTrinkets.BONE_MEAL) then
		Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) 
		Player:EvaluateItems() 
	end
	
	if Player:HasCollectible(CustomCollectibles.ORDINARY_LIFE) then 
		Player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY) 
		Player:EvaluateItems() 
	end
	
	if Player:HasCollectible(CustomCollectibles.RED_BOMBER) then
		if Input.IsActionTriggered(ButtonAction.ACTION_BOMB, Player.ControllerIndex) 
		and CustomData.Items.RED_BOMBER.BombLaunchCooldown <= 0 then
			if Player:GetNumBombs() > 0 then
				CustomData.Items.RED_BOMBER.BombLaunchCooldown = REDBOMBER_LAUNCH_COOLDOWN
			end
		end
		
		if CustomData.Items.RED_BOMBER.BombLaunchCooldown then
			CustomData.Items.RED_BOMBER.BombLaunchCooldown = CustomData.Items.RED_BOMBER.BombLaunchCooldown - 1
		end
	end
	
	if Player:HasCollectible(CustomCollectibles.MAGIC_PEN) then
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
			(not CustomData.Items.MAGIC_PEN.CreepSpewCooldown or CustomData.Items.MAGIC_PEN.CreepSpewCooldown <= 0) then
				-- spewing the creep
				local creepDirection = DIRECTION_VECTOR[Player:GetFireDirection()]:Resized(20)
				for i = 1, 10 do
					Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 4, Player.Position + creepDirection * i, Vector.Zero, nil)
				end
				
				sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 2, false, 1, 0)
				CustomData.Items.MAGIC_PEN.CreepSpewCooldown = MAGICPEN_CREEP_COOLDOWN
				ButtonState_pen = nil
			end
		else
			ButtonState_pen = nil
		end
		
		if CustomData.Items.MAGIC_PEN.CreepSpewCooldown then 
			CustomData.Items.MAGIC_PEN.CreepSpewCooldown = CustomData.Items.MAGIC_PEN.CreepSpewCooldown - 1
		end
	end
	
	if Player:HasCollectible(CustomCollectibles.NERVE_PINCH) then
		for button = 0, 7 do
			if Input.IsActionTriggered(button, Player.ControllerIndex) then
				nervePinchButton = button
			end
		end
		
		if nervePinchButton and Input.IsActionPressed(nervePinchButton, Player.ControllerIndex) then
			CustomData.Items.NERVE_PINCH.Hold = CustomData.Items.NERVE_PINCH.Hold - 1
		else
			CustomData.Items.NERVE_PINCH.Hold = NERVEPINCH_HOLD
		end
	end
	
	if Player:GetData().RejectionUsed then
		for i = 4, 7 do 
			if Input.IsActionTriggered(i, Player.ControllerIndex) then
				Player:GetData().RejectionUsed = false
				sfx:Play(SoundEffect.SOUND_WHIP, 1, 2, false, 1, 0)
				-- launching the CustomFamiliars
				local rejectedBabyTear = Isaac.Spawn(2, CustomTearVariants.REJECTED_BABY, 0, Player.Position, DIRECTION_VECTOR[Player:GetFireDirection()] * 10, Player):ToTear()
				rejectedBabyTear.TearFlags = TearFlags.TEAR_PIERCING | TearFlags.TEAR_POISON	
				rejectedBabyTear:GetSprite():Play("Spin")
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
		
		if player:HasTrinket(CustomTrinkets.GREEDS_HEART) and not isInGhostForm(player) then
			CoinHeartSprite = Sprite()
			
			CoinHeartSprite:Load("gfx/ui/ui_coinhearts.anm2", true)
			if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= LevelCurse.CURSE_OF_THE_UNKNOWN then
				CoinHeartSprite:SetFrame(CustomData.CustomTrinkets.GREEDS_HEART, 0)	-- custom data value is either "CoinHeartEmpty" or "CoinHeartFull"
			else
				CoinHeartSprite:SetFrame("CoinHeartUnknown", 0)
			end
			
			-- since 1.7.6 patch, it is possible to find out whether the player is in full screen and the value of hud offset. cool!
			HeartRenderPos = Vector(122, 11)
			local INSANE_OFFSET = Options.HUDOffset * Vector(20, 12)
			CoinHeartSprite:Render(HeartRenderPos + INSANE_OFFSET, Vector.Zero, Vector.Zero)
		end
		
		if player:HasTrinket(CustomTrinkets.ANGELS_CROWN) and room:GetType() == RoomType.ROOM_TREASURE 
		and not room:IsMirrorWorld() then
			FloorPiece:GetSprite().Scale = Vector(0.25, 0.25)
			FloorPiece:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
			FloorPiece:GetSprite():Load("gfx/backdrop/angel_treasure_room_backdrops.anm2", true)
			FloorPiece:GetSprite():Play("Floor_" .. room:GetRoomShape(), true)
			
			WallPiece:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)
			WallPiece:GetSprite():Load("gfx/backdrop/angel_treasure_room_backdrops.anm2", true)
			WallPiece:GetSprite():Play("Walls_" .. room:GetRoomShape(), true)
		end
		
		if player:HasCollectible(CustomCollectibles.CEILING_WITH_THE_STARS) and (room:GetType() == 18 or room:GetType() == 19 or level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()) then
			if not StarCeiling then StarCeiling = Sprite() end
			StarCeiling:Load("gfx/ui/ui_starceiling.anm2", true)
			StarCeiling:SetFrame("Idle", game:GetFrameCount() % 65)
			StarCeiling.Scale = Vector(1.5, 1.5)
			StarCeiling:Render(Vector(300, 200), Vector.Zero, Vector.Zero)
		end
		
		if player:HasCollectible(CustomCollectibles.DNA_REDACTOR) then
			for _, pickupPill in pairs(Isaac.FindInRadius(player.Position, 150, EntityPartition.PICKUP)) do
				if pickupPill.Variant == 70 then
					DNAPillIcon.Scale = Vector(0.5, 0.5)
					
					DNAPillIcon:SetFrame("pill_" .. tostring(pickupPill.SubType), 0)
					DNAPillIcon:Render(Isaac.WorldToScreen(pickupPill.Position + Vector(15, -15)), Vector.Zero, Vector.Zero)
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.RED_MAP) then
			RedMapIcon:SetFrame("RedMap", 0)
			MapRenderPos = Vector(20, 200)
			local INSANE_OFFSET = Options.HUDOffset * Vector(20, 12)
			RedMapIcon:Render(MapRenderPos + INSANE_OFFSET, Vector.Zero, Vector.Zero)
		end
		
		if CustomData and CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown then
			if CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown <= 0 
			and CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown >= -40 then
				SoulIcon:Update()
				SoulIcon:Render(Isaac.WorldToScreen(player.Position + Vector(25, -45)), Vector.Zero, Vector.Zero)
			end
		end
		
		if CustomData and CustomData.Items.MAGIC_PEN.CreepSpewCooldown then
			if CustomData.Items.MAGIC_PEN.CreepSpewCooldown <= 0 
			and CustomData.Items.MAGIC_PEN.CreepSpewCooldown >= -34 then
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
	if Player:HasTrinket(CustomTrinkets.TORN_PAGE) then
		-- book of revelations doesn't cause harbingers to spawn
		if ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS then
			Player:AddSoulHearts(2)
			Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
			return true
		-- satanic bible doesn't cause devil deal items to appear in boss rooms
		elseif ItemUsed == CollectibleType.COLLECTIBLE_SATANIC_BIBLE then
			Player:AddBlackHearts(2)
			Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
			return true
		-- book of sin has a small chance to spawn an item instead of pickup
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SIN and math.random(100) == 1 then
			Isaac.Spawn(5, 100, 0, Isaac.GetFreeNearPosition(Player.Position, 10), Vector.Zero, nil)
			Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
			return true
		-- anarchist cookbook spawns red bombs instead of troll bombs
		elseif ItemUsed == CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK then
			for s = 1, 6 do
				Isaac.Spawn(5, 41, 0, game:GetRoom():GetRandomPosition(10), Vector.Zero, nil)
			end
			Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
			return true
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, rplus.PreUseItem)

						-- MC_ENTITY_TAKE_DMG --									
						------------------------
function rplus:EntityTakeDmg(Entity, Amount, Flags, SourceRef, CooldownFrames)
	local Source = SourceRef.Entity
	local Player = Entity:ToPlayer()

	-- damage inflicted to player; this also allows for better co-op compatibility
	if Player then
		if Player:HasCollectible(CustomCollectibles.TEMPER_TANTRUM) and math.random(100) <= SUPERBERSERK_ENTER_CHANCE then
			Player:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK, true, true, false, true, -1)
			CustomData.Items.TEMPER_TANTRUM.SuperBerserkState = true
		end
		
		if Player:HasTrinket(CustomTrinkets.JUDAS_KISS)
		and Source and Source:IsActiveEnemy(false) then
			Source:AddEntityFlags(EntityFlag.FLAG_BAITED)
		end
		
		if Player:HasTrinket(CustomTrinkets.GREEDS_HEART) and CustomData.CustomTrinkets.GREEDS_HEART == "CoinHeartFull"
		and not isInGhostForm(Player) and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isSelfDamage(Flags, "greedsheart") then
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 2, false, 1, 0)
			CustomData.CustomTrinkets.GREEDS_HEART = "CoinHeartEmpty"
			Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
			
			return false
		end
		
		if Player:HasCollectible(CustomCollectibles.BIRD_OF_HOPE) and CustomData and CustomData.Items.BIRD_OF_HOPE.BirdCaught == false then
			return false
		end
		
		if Player:HasTrinket(CustomTrinkets.MAGIC_SWORD, false) and not Player:HasTrinket(TrinketType.TRINKET_DUCT_TAPE) 
		and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE and not isSelfDamage(Flags) then
			sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 2, false, 1, 0)
			Player:TryRemoveTrinket(CustomTrinkets.MAGIC_SWORD)
			Isaac.Spawn(5, 350, CustomTrinkets.WAIT_NO, Player.Position, Vector.Zero, nil)
		end
		
		if Player:HasTrinket(CustomTrinkets.EDENS_LOCK)
		and not isSelfDamage(Flags) then
			local freezePreventChecker = 0
				
			repeat
				ID = Player:GetDropRNG():RandomInt(728) + 1
				freezePreventChecker = freezePreventChecker + 1
			until (Player:HasCollectible(ID, true)
			and Isaac.GetItemConfig():GetCollectible(ID).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
			and Isaac.GetItemConfig():GetCollectible(ID).Type % 3 == 1)	-- passive or familiar (1 or 4)
			or freezePreventChecker == 10000
			
			if freezePreventChecker < 10000 then
				Player:RemoveCollectible(ID, true, -1, true)
			else 
				return true
			end
			
			repeat 
				newID = GetUnlockedVanillaCollectible(true)
			until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
			Player:AddCollectible(newID, 0, false, -1, 0)
			
			sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 2, false, 1, 0)
		end
		
		if Player:HasCollectible(CustomCollectibles.RED_BOMBER)
		and Flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
			return false
		end
		
		if Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isInGhostForm(Player) and CustomData.Items.BLOODVESSEL.DamageFlag == false 
		and not isSelfDamage(Flags, "bloodvessel") then
			for i = 1, #CustomCollectibles.BLOOD_VESSELS do
				if Player:HasCollectible(CustomCollectibles.BLOOD_VESSELS[i]) then
					if i == 7 then
						CustomData.Items.BLOODVESSEL.DamageFlag = true
						Player:TakeDamage(7, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(Player), 18)
						Player:RemoveCollectible(CustomCollectibles.BLOOD_VESSELS[i])
						Player:AddCollectible(CustomCollectibles.BLOOD_VESSELS[1])
						CustomData.Items.BLOODVESSEL.DamageFlag = false
					else
						Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Player), 18)
						Player:RemoveCollectible(CustomCollectibles.BLOOD_VESSELS[i])
						Player:AddCollectible(CustomCollectibles.BLOOD_VESSELS[i+1])
					end
					
					return false
				end
			end
		end
		
		if Player:HasCollectible(CollectibleType.COLLECTIBLE_CRACKED_ORB) then
			for _, chest in pairs(Isaac.FindByType(5, CustomPickups.SCARLET_CHEST, -1, false, false)) do
				if chest.SubType == 0 or chest.SubType == 2 then
					openScarletChest(chest)
					break
				end
			end
		end
		
		if Player:HasTrinket(CustomTrinkets.KEY_KNIFE) then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			if roll < DARK_ARTS_CHANCE * Player:GetTrinketMultiplier(CustomTrinkets.KEY_KNIFE) then
				Player:UseActiveItem(CollectibleType.COLLECTIBLE_DARK_ARTS, UseFlag.USE_NOANIM, -1)
			end
		end
		
		if CustomData.TaintedHearts.ZEALOT>0 and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE then 
			for i = 1, 2 do
					repeat 
						newID = GetUnlockedVanillaCollectible()
					until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
					Player:AddItemWisp(newID, Player.Position, true)
			end
				CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT - 1
		end

		if CustomData.TaintedHearts.EMPTY>0 and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE  then 	
				CustomData.TaintedHearts.EMPTY = CustomData.TaintedHearts.EMPTY - 1
		
		end

		-- -- take damage with custom hearts
		-- if CustomData.TaintedHearts.ZEALOT > 0 and not isInGhostForm(Player) and CustomData.TaintedHearts.SOILED==0 and CustomData.TaintedHearts.DAUNTLESS==0 then
			-- if not isSelfDamage(Flags, "taintedhearts") then
				-- CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT - Amount
				-- if CustomData.TaintedHearts.ZEALOT < 0 then 
					-- CustomData.TaintedHearts.ZEALOT = 0
				-- end
				-- Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				-- return false
			-- elseif isSelfDamage(Flags, "taintedhearts") and Player:GetHearts() == 0 then 
				-- CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT - Amount
				-- if CustomData.TaintedHearts.ZEALOT < 0 then 
					-- CustomData.TaintedHearts.ZEALOT = 0
				-- end
				-- Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				-- return false
			-- else 
				-- return true
			-- end
		-- end


		-- if CustomData.TaintedHearts.SOILED > 0 and not isInGhostForm(Player) and CustomData.TaintedHearts.DAUNTLESS==0 then
			-- if not isSelfDamage(Flags, "taintedhearts") then
				-- CustomData.TaintedHearts.SOILED = CustomData.TaintedHearts.SOILED - Amount
				-- if CustomData.TaintedHearts.SOILED < 0 then 
					-- CustomData.TaintedHearts.SOILED = 0
				-- end
				-- Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				-- return false
			-- elseif isSelfDamage(Flags, "taintedhearts") and Player:GetHearts() == 0 then 
				-- CustomData.TaintedHearts.SOILED = CustomData.TaintedHearts.SOILED - Amount
				-- if CustomData.TaintedHearts.SOILED < 0 then 
					-- CustomData.TaintedHearts.SOILED = 0
				-- end
				-- Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				-- return false
			-- else 
				-- return true
			-- end
		-- end

		-- if CustomData.TaintedHearts.DAUNTLESS > 0 and not isInGhostForm(Player) then
			-- if not isSelfDamage(Flags, "taintedhearts") then
				-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS - Amount
				-- if CustomData.TaintedHearts.DAUNTLESS < 0 then 
					-- CustomData.TaintedHearts.DAUNTLESS = 0
				-- end
				-- Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				-- return false
			-- elseif isSelfDamage(Flags, "taintedhearts") and Player:GetHearts() == 0 then 
				-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS - Amount
				-- if CustomData.TaintedHearts.DAUNTLESS < 0 then 
					-- CustomData.TaintedHearts.DAUNTLESS = 0
				-- end
				-- Player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(Entity), 24)
				-- return false
			-- else 
				-- return true
			-- end
		-- end
		
	-- damage inflicted to enemies
	elseif Entity:IsVulnerableEnemy() then
		if Source and Source.Type == 1000 and Source.Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL and Source.SubType == 4 then
			if math.random(100) < 5 then 
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
		
		if Source and Source.Type == 1000 and Source.Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL and Source.SubType == 5 then
			Entity.Friction = 0
			
			return false
		end
		
		if CustomData.Items.TEMPER_TANTRUM.SuperBerserkState 
		and not Entity:IsBoss() and Entity.Type ~= 951 -- for the Beast fight protection, lmao 
		and math.random(100) <= SUPERBERSERK_DELETE_CHANCE then
			table.insert(CustomData.Items.TEMPER_TANTRUM.ErasedEnemies, Entity.Type)
		end
		
		if ABSepNumber then
			for i = 1, #EntitiesGroupA do 
				if Entity:GetData() == EntitiesGroupA[i]:GetData() and EntitiesGroupB[i] and Source and Source.Type < 9 then 
					EntitiesGroupB[i]:TakeDamage(Amount * 0.6, 0, EntityRef(Entity), 0)
				end 
			end
			for i = 1, #EntitiesGroupB do 
				if Entity:GetData() == EntitiesGroupB[i]:GetData() and EntitiesGroupA[i] and Source and Source.Type < 9 then 
					EntitiesGroupA[i]:TakeDamage(Amount * 0.6, 0, EntityRef(Entity), 0)
				end 
			end
		end
		
		if Source and Source.Type == 2 and Source.Variant == CustomTearVariants.CEREMONIAL_BLADE then
			Entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			sfx:Play(SoundEffect.SOUND_KNIFE_PULL, 1, 2, false, 1, 0)
		end
		
		if Source and Source.Type == 8 and Source:GetData().IsCeremonial and math.random(100) <= CEREM_DAGGER_LAUNCH_CHANCE then -- knife synergy
			Entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, rplus.EntityTakeDmg)

						-- MC_POST_NPC_INIT --											
						-----------------------
function rplus:OnNPCInit(NPC)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasTrinket(CustomTrinkets.BABY_SHOES) then
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
		
		if player:HasTrinket(CustomTrinkets.KEY_TO_THE_HEART) and math.random(100) <= HEARTKEY_CHANCE * player:GetTrinketMultiplier(CustomTrinkets.KEY_TO_THE_HEART) 
		and NPC.MaxHitPoints >= 10 then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, CustomPickups.FLESH_CHEST, 0, NPC.Position, NPC.Velocity, nil)
		end
		
		if player:HasCollectible(CustomCollectibles.CHERRY_FRIENDS) and math.random(100) <= CHERRY_SPAWN_CHANCE then
			Isaac.Spawn(3, CustomFamiliars.CHERRY, 1, NPC.Position, Vector.Zero, nil)
			sfx:Play(SoundEffect.SOUND_BABY_HURT, 1, 2, false, 1, 0)
		end
		
		if player:HasCollectible(CustomCollectibles.CEREMONIAL_BLADE) and not NPC:IsBoss() and NPC:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
			Isaac.Spawn(5, 300, CustomConsumables.SACRIFICIAL_BLOOD, NPC.Position, Vector.Zero, nil)
		end
		
		if player:HasCollectible(CustomCollectibles.GUSTY_BLOOD) and NPC:IsEnemy() and CustomData.Items.GUSTY_BLOOD.CurrentSpeed < 10 then
			CustomData.Items.GUSTY_BLOOD.CurrentTears = CustomData.Items.GUSTY_BLOOD.CurrentTears + 1
			CustomData.Items.GUSTY_BLOOD.CurrentSpeed = CustomData.Items.GUSTY_BLOOD.CurrentSpeed + 1
			player:SetColor(Color(1, 0.5, 0.5, 1, 0, 0, 0), 15, 1, false, false)
			player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
		end
		
		if player:HasCollectible(CustomCollectibles.KEEPERS_PENNY) and room:GetType() == RoomType.ROOM_SHOP 
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
		if player:HasCollectible(CustomCollectibles.ANGELS_WINGS) and NPC:HasEntityFlags(EntityFlag.FLAG_SLOW) then
			local dogmababy = Isaac.Spawn(950, 10, 0, NPC.Position, Vector.Zero, nil) 
			dogmababy:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			dogmababy:AddEntityFlags(EntityFlag.FLAG_CHARM)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, rplus.OnNPCDeath)

						-- MC_POST_NPC_RENDER --											
						------------------------
function rplus:OnNPCRender(NPC, _)
	if NPC:GetData().IsCrippled then
		
		NPC.Friction = 120 / (120 + game:GetFrameCount() - NPC:GetData().CrippleStartFrame)
		--print(NPC.Friction)
		
		if (NPC:HasMortalDamage() or NPC.Friction <= 0.2) and not NPC:GetData().CrippleDeathBurst then
			if NPC.Friction <= 0.2 then NPC:Kill() end
			
			RNGobj:SetSeed(Random() + 1, 1)
			local NumTears = RNGobj:RandomInt(5) + 5
			
			for i = 1, NumTears do
				local newTear = Isaac.Spawn(2, 0, 0, NPC.Position, Vector.FromAngle(math.random(360)) * (math.random(20) / 10), NPC):ToTear()
				newTear.FallingSpeed = -20
				newTear.FallingAcceleration = 0.4
				newTear:AddTearFlags(TearFlags.TEAR_SLOW)
				newTear:SetColor(Color(0.15, 0.15, 0.15, 1, 0, 0, 0), 300, 1, false, false)
			end
			
			NPC:GetData().CrippleDeathBurst = true
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, rplus.OnNPCRender)

						-- MC_POST_PICKUP_INIT -- 										
						-------------------------
function rplus:OnPickupInit(Pickup)	
	local room = game:GetRoom()
	local level = game:GetLevel()
	local stage = level:GetStage()
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if (Pickup:GetSprite():IsPlaying("Appear") or Pickup:GetSprite():IsPlaying("AppearFast")) 
		and Pickup:GetSprite():GetFrame() == 0 then
			if player:HasTrinket(CustomTrinkets.BASEMENT_KEY) and Pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST 
			and math.random(100) <= BASEMENTKEY_CHANCE * player:GetTrinketMultiplier(CustomTrinkets.BASEMENT_KEY) 
			and room:GetType() ~= RoomType.ROOM_CHALLENGE then
				Pickup:Morph(5, PickupVariant.PICKUP_OLDCHEST, 0, true, true, false)
			end
			
			local CoinSubTypesByVal = {1, 4, 6, 2, 3, 5, 7} -- penny, doublepack, sticky nickel, nickel, dime, lucky penny, golden penny
			if Pickup.Variant == 20 and Pickup.SubType ~= 7 and player:HasTrinket(CustomTrinkets.SLEIGHT_OF_HAND) 
			and math.random(100) <= SLEIGHTOFHAND_UPGRADE_CHANCE * player:GetTrinketMultiplier(CustomTrinkets.SLEIGHT_OF_HAND) then
				sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 2, false, 1, 0)
				for i = 1, #CoinSubTypesByVal do
					if CoinSubTypesByVal[i] == Pickup.SubType then CurType = i break end
				end
				Pickup:Morph(5, 20, CoinSubTypesByVal[CurType + 1], true, true, false)
			end
			
			if math.random(100) <= FLESHCHEST_REPLACE_CHANCE 
			and (Pickup.Variant == PickupVariant.PICKUP_SPIKEDCHEST or Pickup.Variant == PickupVariant.PICKUP_MIMICCHEST) 
			and room:GetType() ~= RoomType.ROOM_CHALLENGE then
				Pickup:Morph(5, CustomPickups.FLESH_CHEST, 0, true, true, false)
				sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			end
			
			-- TAINTED HEARTS REPLACEMENT --
			if Pickup.Variant == 10 and not noCustomHearts and room:GetType() ~= RoomType.ROOM_BOSS then
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomFloat() * 1000
				local st = Pickup.SubType
				local baseChanceChanged = false
				
				if st == HeartSubType.HEART_FULL or st == HeartSubType.HEART_HALF then
					local baseChance = 7.5
					if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENA_B or
					player:HasCollectible(CollectibleType.COLLECTIBLE_HYPERCOAGULATION) or 
					player:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_CHAD) or 
					player:HasTrinket(TrinketType.TRINKET_BLOODY_PENNY) or
					player:HasCollectible(CollectibleType.COLLECTIBLE_OLD_BANDAGE) or
					player:HasCollectible(CollectibleType.COLLECTIBLE_SHARD_OF_GLASS) or 
					player:HasCollectible(CollectibleType.COLLECTIBLE_SHARP_STRAW) or
					player:HasCollectible(CollectibleType.COLLECTIBLE_GIMPY) or
					player:HasCollectible(CustomCollectibles.CHERRY_FRIENDS) then
					baseChance = 1 baseChanceChanged = true end
					
					-- 0.75% broken heart
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_BROKEN, true, true, false)
					-- 0.75% enigma heart
					elseif roll < baseChance * 2 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_ENIGMA, true, true, false) end
				elseif st == HeartSubType.HEART_SOUL then
					local baseChance = 150
					if player:HasCollectible(CollectibleType.COLLECTIBLE_RELIC) or
					player:HasCollectible(CollectibleType.COLLECTIBLE_MITRE) or
					player:HasCollectible(CollectibleType.COLLECTIBLE_GIMPY) then
					baseChance = 50 baseChanceChanged = true end
					
					-- 15% fettered heart
					if roll < baseChance and stage > 1 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_FETTERED, true, true, false) end
				elseif st == HeartSubType.HEART_ETERNAL then
					
				elseif st == HeartSubType.HEART_DOUBLEPACK then
					local baseChance = 250
					if player:HasCollectible(CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE) then
					baseChance = 50 baseChanceChanged = true end
					
					-- 25% hoarded heart
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_HOARDED, true, true, false) end
				elseif st == HeartSubType.HEART_BLACK then
					local baseChance = 250
					if player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_BUM) or
					player:HasTrinket(TrinketType.TRINKET_BLACK_LIPSTICK) or
					player:HasTrinket(TrinketType.TRINKET_DAEMONS_TAIL) then
					baseChance = 50 baseChanceChanged = true end
				
					-- 25% deserted heart
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_DESERTED, true, true, false)
					-- 25% benighted heart
					elseif roll < baseChance * 2 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_BENIGHTED, true, true, false) end
				elseif st == HeartSubType.HEART_GOLDEN then
					local baseChance = 300
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_ZEALOT, true, true, false) end	
				elseif st == HeartSubType.HEART_HALF_SOUL then
					
				elseif st == HeartSubType.HEART_SCARED then
					
				elseif st == HeartSubType.HEART_BLENDED then
					local baseChance = 300
					
					-- 30% deserted heart
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_DESERTED, true, true, false) end
				elseif st == HeartSubType.HEART_BONE then
				
				elseif st == HeartSubType.HEART_ROTTEN then
					local baseChance = 300 
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_EMPTY, true, true, false) end
				
				end
				
				-- 1% capricious heart
				local baseChance = 10
				if baseChanceChanged then
				baseChance = 2 end
				
				if roll < baseChance
				then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_CAPRICIOUS, true, true, false) end
			end
		end
	end
		
	if (Pickup.Variant == CustomPickups.FLESH_CHEST or Pickup.Variant == CustomPickups.BLACK_CHEST or Pickup.Variant == CustomPickups.SCARLET_CHEST)
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
	
	if Pickup.Variant == CustomPickups.FLESH_CHEST and Pickup.SubType == 0 and not player:GetSprite():IsPlaying("Hit") then
		Collider:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(Pickup), 24)
		CustomData.FleshChestConsumedHP = CustomData.FleshChestConsumedHP + 1
		Pickup:GetSprite():Play("TakeHealth")
		
		if ((CustomData.FleshChestConsumedHP > 3 and math.random(100) < FLESHCHEST_OPEN_CHANCE) or CustomData.FleshChestConsumedHP == 8)
		then
			CustomData.FleshChestConsumedHP = 0
			-- subtype 1: opened chest (need to remove)
			Pickup.SubType = 1
			-- setting some data for pickup, because it is deleted on entering a new room, and the pickup is removed as well
			Pickup:GetData()["IsInRoom"] = true
			Pickup:GetSprite():Play("Open")
			sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
			RNGobj:SetSeed(Random() + 1, 1)
			local DieRoll = RNGobj:RandomFloat()
			
			if DieRoll < 0.33 then
				local freezePreventChecker = 0
				
				repeat
					Item = CustomItempools.FLESH_CHEST[math.random(#CustomItempools.FLESH_CHEST)]
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
			else
				RNGobj:SetSeed(Pickup.DropSeed, 1)
				local NumOfPickups = RNGobj:RandomInt(4) + 4 -- 4 to 7 CustomPickups
				
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
					Isaac.Spawn(5, variant, subtype, Pickup.Position, Vector.FromAngle(math.random(360)) * 4, Pickup)
				end
				Isaac.Spawn(5, 350, CustomItempools.FLESHCHEST_trinkets[math.random(#CustomItempools.FLESHCHEST_trinkets)], Pickup.Position, Vector.FromAngle(math.random(360)) * 4, Pickup)
			end
		end
	end
	
	if player:HasTrinket(CustomTrinkets.GREEDS_HEART) and CustomData.CustomTrinkets.GREEDS_HEART == "CoinHeartEmpty" and Pickup.Variant == 20 and Pickup.SubType ~= 6 
	and not isInGhostForm(player) 
	-- if the player's Keeper, they should be at full health to gain a new coin heart
	and (player:GetHearts() == player:GetMaxHearts() or (player:GetPlayerType() ~= 14 and player:GetPlayerType() ~= 33)) then
		player:AddCoins(-1)
		CustomData.CustomTrinkets.GREEDS_HEART = "CoinHeartFull"
	end
	
	-- this monster is able to 100% (so far) detect whether we buy something and whether we don't
	-- mad? cry about it
	if player:HasCollectible(CustomCollectibles.TWO_PLUS_ONE) 
	and Pickup.Price > -6 and Pickup.Price ~= 0 	-- this pickup costs something
	and not player:IsHoldingItem()		-- we're not holding another pickup right now
	then
		if (Pickup.Price == -1 and player:GetMaxHearts() >= 2)
		or (Pickup.Price == -2 and player:GetMaxHearts() >= 4)
		or (Pickup.Price == -3 and player:GetSoulHearts() >= 6)
		or (Pickup.Price == -4 and player:GetMaxHearts() >= 2 and player:GetSoulHearts() >= 4)	-- this devil deal is affordable
		then
			CustomData.Items.TWO_PLUS_ONE.ItemsBought_HEARTS = CustomData.Items.TWO_PLUS_ONE.ItemsBought_HEARTS + 1
		elseif Pickup.Price > 0 and player:GetNumCoins() >= Pickup.Price	-- this shop item is affordable
		and not (Pickup.Variant == 90 and not (player:NeedsCharge(0) or player:NeedsCharge(1) or player:NeedsCharge(2)))
		and not (Pickup.Variant == 10 and Pickup.SubType == 1 and not player:CanPickRedHearts())
		and not (Pickup.Variant == 10 and Pickup.SubType == 3 and not player:CanPickSoulHearts())
		then
			if CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS == 2 then
				CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS = 0
				for _, pickup in pairs(Isaac.FindByType(5, -1, -1, false, false)) do
					if pickup:ToPickup().Price == 1 then
						pickup:ToPickup().AutoUpdatePrice = true
					end
				end
			else
				CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS = CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS + 1
			end
		end
	end
	
	if Pickup.Variant == 10 and player:CanPickRedHearts()  
	and (Pickup.SubType == 1 or Pickup.SubType == 2 or Pickup.SubType == 5 or Pickup.SubType == 12) then
		if ((game:GetFrameCount() - CustomData.CustomPills.YUCK.UseFrame) <= 900 and player:GetData()['usedYuck'])
		or ((game:GetFrameCount() - CustomData.CustomPills.YUCK.UseFrame) <= 1800 and player:GetData()['usedHorseYuck']) then
			for i = 1, math.random(3) do 
				Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector.Zero, nil) 
			end
		else
			player:GetData()['usedHorseYuck'] = false
			player:GetData()['usedYuck'] = false
		end
		
		if ((game:GetFrameCount() - CustomData.CustomPills.YUM.UseFrame) <= 900 and player:GetData()['usedYum'])
		or ((game:GetFrameCount() - CustomData.CustomPills.YUM.UseFrame) <= 1800 and player:GetData()['usedHorseYum']) then
			YumStat = math.random(4)
			if YumStat == 1 then -- damage
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				CustomData.CustomPills.YUM.NumDamage = CustomData.CustomPills.YUM.NumDamage + 1
				player:GetData()['GetYumDamage'] = true						
			elseif YumStat == 2 then -- tears
				player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
				CustomData.CustomPills.YUM.NumTears = CustomData.CustomPills.YUM.NumTears + 1
				player:GetData()['GetYumTears'] = true						
			elseif YumStat == 3 then -- shotspeed
				player:AddCacheFlags(CacheFlag.CACHE_RANGE)
				CustomData.CustomPills.YUM.NumRange = CustomData.CustomPills.YUM.NumRange + 1
				player:GetData()['GetYumRange'] = true
			elseif YumStat == 4 then -- luck
				player:AddCacheFlags(CacheFlag.CACHE_LUCK)
				CustomData.CustomPills.YUM.NumLuck = CustomData.CustomPills.YUM.NumLuck + 1
				player:GetData()['GetYumLuck'] = true
			end
			player:EvaluateItems()
		else
			player:GetData()['usedHorseYum'] = false
			player:GetData()['usedYum'] = false
		end
	end
	
	if Pickup.Variant == 10 and Pickup.SubType >= CustomPickups.TaintedHearts.HEART_BROKEN and Pickup.SubType <= CustomPickups.TaintedHearts.HEART_DESERTED 
	and not Pickup:GetSprite():IsPlaying("Collect") then
		-- tainted hearts
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_BROKEN then
			player:AddMaxHearts(2)
			player:AddHearts(2)
			player:AddBrokenHearts(1)
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_HOARDED then
			if player:CanPickRedHearts() then
				player:AddHearts(8)
				sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_BENIGHTED then
			if player:CanPickBlackHearts() then
				player:AddBlackHearts(2)
				player:GetData()['NumPickedBenightedHearts'] = player:GetData()['NumPickedBenightedHearts'] or 0
				player:GetData()['NumPickedBenightedHearts'] = player:GetData()['NumPickedBenightedHearts'] + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
				sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_ENIGMA then
			player:AddMaxHearts(2)
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_CAPRICIOUS then
			for i = 1, 3 do 
				local newHeart = Isaac.Spawn(5, 10, math.random(12), Pickup.Position, Vector.FromAngle(math.random(360)) * 3, nil)
			end
			sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 1, 2, false, 1, 0)
		end
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_EMPTY and not isInGhostForm(player) then
			if math.floor((player:GetMaxHearts() + player:GetSoulHearts()) /2  + player:GetBoneHearts()+0.5) > CustomData.TaintedHearts.EMPTY then
				CustomData.TaintedHearts.EMPTY = CustomData.TaintedHearts.EMPTY + 1
				sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
			else return false end
		end

		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_FETTERED then
			if (player:GetNumKeys() > 0 or player:HasGoldenKey()) and player:CanPickSoulHearts() then
				player:AddSoulHearts(3)
				if not player:HasGoldenKey() then player:AddKeys(-1) end
				sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 2, false, 1, 0)
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_ZEALOT and not isInGhostForm(player) then
			if math.floor((player:GetMaxHearts() + player:GetSoulHearts()) /2  + player:GetBoneHearts()+0.5) > CustomData.TaintedHearts.ZEALOT then
				CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT + 1
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_DESERTED then
			if player:CanPickRedHearts() then player:AddHearts(1) sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0) elseif player:CanPickBlackHearts() then player:AddBlackHearts(1) sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0) end
			if player:CanPickRedHearts() then player:AddHearts(1) sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0) elseif player:CanPickBlackHearts() then player:AddBlackHearts(1) sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0) end
		end
		
		-- if Pickup.SubType == CustomPickups.TaintedHearts.HEART_ZEALOT then			
			-- if totalhealth < maxhealth then 
				-- if totalhealth % 2 == 0 or CustomData.TaintedHearts.ZEALOT % 2 == 1 or CustomData.TaintedHearts.SOILED % 2 == 1 then 
					-- CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT + 2
				-- elseif totalhealth == maxhealth - 1 and player:GetMaxHearts()~=maxhealth-2 then 
					-- player:AddSoulHearts(-1)
					-- CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT + 2
				-- elseif player:GetSoulHearts() % 2 == 1 or player:GetBlackHearts() % 2 == 1 then 
					-- player:AddSoulHearts(1)
					-- CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT + 1
				-- end
			-- elseif totalhealth == maxhealth and player:GetSoulHearts()>0 and player:GetMaxHearts()~=maxhealth then 
				-- player:AddSoulHearts(-2)
				-- CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT + 2
			-- else return false end
		-- end

		-- if Pickup.SubType == CustomPickups.TaintedHearts.HEART_SOILED then
			-- if player:CanPickRottenHearts() then			
				-- player:AddRottenHearts(1)
				-- CustomData.TaintedHearts.SOILED = CustomData.TaintedHearts.SOILED + 1
			-- else
				-- return false
			-- end
		-- end

		-- if Pickup.SubType == CustomPickups.TaintedHearts.HEART_DAUNTLESS then
			-- if totalhealth<maxhealth then 
				-- if totalhealth % 2 == 0 or CustomData.TaintedHearts.DAUNTLESS % 3 == 1 then 
					-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS + 3
				-- elseif totalhealth == maxhealth - 1 then 
					-- player:AddSoulHearts(-1)
					-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS + 3
				-- elseif player:GetSoulHearts() % 2 == 1 or player:GetBlackHearts() % 2 == 1 then 
					-- player:AddSoulHearts(1)
					-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS + 2
				-- elseif CustomData.TaintedHearts.ZEALOT % 2 == 1 then 
					-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS + 2
					-- CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT + 1
				-- elseif CustomData.TaintedHearts.SOILED % 2 == 1 then 
					-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS + 2
					-- CustomData.TaintedHearts.SOILED = CustomData.TaintedHearts.SOILED + 1
				-- end
			-- elseif totalhealth == maxhealth and player:GetSoulHearts()>0 and player:GetMaxHearts()~=maxhealth then 
				-- player:AddSoulHearts(-2)
				-- CustomData.TaintedHearts.DAUNTLESS = CustomData.TaintedHearts.DAUNTLESS + 3
			-- else return false end
		-- end
		
		Pickup:GetSprite():Play("Collect")
	end
	
	if Pickup.Variant == CustomPickups.BLACK_CHEST and Pickup.SubType == 0 then		
		-- setting some data for pickup, because it is deleted on entering a new room, and the pickup is removed as well
		Pickup:GetData()["IsInRoom"] = true
		Pickup:GetSprite():Play("Open")
		sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
		player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(Pickup), 24)
		RNGobj:SetSeed(Random() + 1, 1)
		local DieRoll = RNGobj:RandomFloat()
		
		if DieRoll < 0.1 then
			local freezePreventChecker = 0
			
			repeat
				Item = CustomItempools.BLACK_CHEST[math.random(#CustomItempools.BLACK_CHEST)]
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
			
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			for i, v in pairs(DropTables.BLACK_CHEST) do
				if roll < DropTables.BLACK_CHEST[i][1] then
					for x, y in pairs(DropTables.BLACK_CHEST[i][2]) do
						Isaac.Spawn(5, y[1], y[2], Pickup.Position, Vector.FromAngle(math.random(360)) * 3, Pickup)
					end
					break
				end
			end
		else
			-- subtype 1: opened chest with nothing (need to remove)
			Pickup.SubType = 1		
		end
	end
	
	if Pickup.Variant == CustomPickups.SCARLET_CHEST and (Pickup.SubType == 0 or Pickup.SubType == 2) then
		if not canOpenScarletChests(player) or Pickup:GetSprite():IsPlaying("Appear") then return false end
		
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
				sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 2, false, 1, 0)
				SCARLETCHEST_REPLACE_CHANCE = 0
				game:GetRoom():SpawnClearAward()
				SCARLETCHEST_REPLACE_CHANCE = 12
				return false
			end
		else
			return false
		end
		
		openScarletChest(Pickup)
	end
	
	if player:HasCollectible(CustomCollectibles.STARGAZERS_HAT) 
	and Pickup.Variant == 10 then
		local HatSlot = 0
		local addCharges
	
		if Pickup.SubType == HeartSubType.HEART_SOUL then addCharges = 2
		elseif Pickup.SubType == HeartSubType.HEART_HALF_SOUL then addCharges = 1 end
		if type(addCharges) == 'nil' then return nil end
		
		if player:GetActiveItem(1) == CustomCollectibles.STARGAZERS_HAT and player:GetActiveItem(1) ~= CustomCollectibles.STARGAZERS_HAT then HatSlot = 1 end
		if player:GetActiveCharge(HatSlot) >= 4 then return nil end
		
		player:SetActiveCharge(player:GetActiveCharge(HatSlot) + addCharges, HatSlot)
		if player:GetActiveCharge(HatSlot) >= 4 then sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 2, false, 1, 0) else sfx:Play(SoundEffect.SOUND_BEEP, 1, 2, false, 1, 0) end
		Pickup:Remove()
		return false
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, rplus.PickupCollision)

						-- MC_POST_PICKUP_UPDATE -- 										
						---------------------------
function rplus:PostPickupUpdate(Pickup)	
	-- items spawned by Auction Gavel
	if Pickup.ShopItemId == -321 and Pickup.SpawnerType == 1 and Pickup.Price >= 15 then
		if type(Pickup:GetData().Data) == 'nil' then
			Pickup:Remove()
		else
			local pf = Pickup.FrameCount
			
			if pf % 6 == 0 then
				Pickup.Price = math.min(math.random(15 + pf // 24, 25 + pf // 24), 99)
			end
		end
	end
	
	if Pickup.Variant == 10 and Pickup.SubType >= CustomPickups.TaintedHearts.HEART_BROKEN and Pickup.SubType <= CustomPickups.TaintedHearts.HEART_DESERTED then
		if Pickup:GetSprite():IsFinished("Collect") then Pickup:Remove() end
	end	
end
rplus:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, rplus.PostPickupUpdate)

						-- MC_POST_TEAR_UPDATE --
						-------------------------
function rplus:OnTearUpdate(Tear)
	local Player
	if Tear.Parent then Player = Tear.Parent:ToPlayer() elseif Tear.SpawnerEntity then Player = Tear.SpawnerEntity:ToPlayer() end
	if not Player then return end
	local tearSprite = Tear:GetSprite()
	
	-- substitute for MC_POST_TEAR_INIT
	-- this callback was a complete disaster, because the tear parent isn't accesible on init
	if Tear.FrameCount == 1 then
		if Player:HasCollectible(CustomCollectibles.CEREMONIAL_BLADE) and math.random(100) <= CEREM_DAGGER_LAUNCH_CHANCE then
			-- launching the dagger
			local BladeTear = Isaac.Spawn(2, CustomTearVariants.CEREMONIAL_BLADE, 0, Player.Position, Tear.Velocity, Player):ToTear()
			BladeTear:AddTearFlags(TearFlags.TEAR_PIERCING) 
			BladeTear:GetSprite():Load("gfx/002.120_ceremonial_blade_tear.anm2", true)
			BladeTear:GetSprite():Play("Idle")
		end
		
		if Player:HasCollectible(CustomCollectibles.SCALPEL) then 
			Tear.Velocity = -Tear.Velocity
		end
		
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART) and Tear.Variant ~= CustomTearVariants.CEREMONIAL_BLADE then
			tearSprite.Scale = Vector(0.66, 0.66)
			tearSprite:Load("gfx/002.121_sinners_heart_tear.anm2", true)
			tearSprite:Play("MoveVert")
		end
		
		if Player:HasCollectible(CustomCollectibles.ANGELS_WINGS) and Tear.Variant ~= CustomTearVariants.CEREMONIAL_BLADE then
			tearSprite.Scale = Vector(0.66, 0.66)
			tearSprite:Load("gfx/002.125_static_feather_tear.anm2", true)
			tearSprite:Play("MoveVert") 
		end
		
		if Tear.Variant == CustomTearVariants.REJECTED_BABY then
			Tear.CollisionDamage = Player.Damage * 4 * #Player:GetData().FamiliarsInBelly
		end
	end
	
	if Tear.Variant == CustomTearVariants.CEREMONIAL_BLADE or Player:HasCollectible(CustomCollectibles.SINNERS_HEART) or Player:HasCollectible(CustomCollectibles.ANGELS_WINGS) then
		tearSprite.Rotation = Tear.Velocity:GetAngleDegrees() + 90
	end
	
	if Tear.Variant == CustomTearVariants.REJECTED_BABY and Tear.Height > -5 then
		local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, Tear.Position, Vector.Zero, Tear):ToEffect()
		splash:SetColor(Color(0.87, 0.24, 0.18, 1, 0, 0, 0), 100, 1, false, false)
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, rplus.OnTearUpdate)

						-- MC_PRE_TEAR_COLLISION --										
						---------------------------	
function rplus:TearCollision(Tear, Collider, _)
	if not (Collider:IsVulnerableEnemy() and not Collider:IsBoss()) then return end
	
	local Player
	if Tear.Parent then Player = Tear.Parent:ToPlayer()
	elseif Tear.SpawnerEntity then Player = Tear.SpawnerEntity:ToPlayer() end
	if not Player then return end
	
	if Tear.Variant == CustomTearVariants.ANTIMATERIAL_CARD and Collider.Type ~= 951 then
		table.insert(CustomData.Items.TEMPER_TANTRUM.ErasedEnemies, Collider.Type)
	end
		
	if Player:HasCollectible(CustomCollectibles.CROSS_OF_CHAOS) and not Collider:GetData().IsCrippled then
		RNGobj:SetSeed(Random() + 1, 1)
		local roll = RNGobj:RandomFloat() * 100
		local trueCrippleChance = math.max(CRIPPLE_TEAR_CHANCE, CRIPPLE_TEAR_CHANCE + Player.Luck / 2)
		trueCrippleChance = math.min(trueCrippleChance, 7)
				
		if roll < trueCrippleChance then
			Collider:GetData().IsCrippled = true
			Collider:GetData().CrippleStartFrame = game:GetFrameCount()
			Collider:GetData().CrippleDeathBurst = false
			local crippleHands = Isaac.Spawn(1000, CripplingHandsHelper, 0, Collider.Position + Vector(0, 5), Vector.Zero, Collider):ToEffect()
			crippleHands:GetSprite():Play("ClawsAppearing")
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, rplus.TearCollision)

						-- MC_EVALUATE_CACHE --							
						-----------------------
function rplus:UpdateStats(Player, Flag) 
	-- If any Stat-Changes are done, just check for the collectible in the cacheflag (be sure to set the cacheflag in the items.xml)
	if Flag == CacheFlag.CACHE_DAMAGE then
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART) then
			Player.Damage = Player.Damage + CustomStatups.SINNERSHEART_DMG_ADD
			Player.Damage = Player.Damage * CustomStatups.SINNERSHEART_DMG_MUL
		end
		
		if CustomData and CustomData.Items.MARK_OF_CAIN == "player revived" then
			Player.Damage = Player.Damage + #MyFamiliars * CustomStatups.MARKCAIN_DMG
		end
		
		if CustomData and CustomData.Cards.SACRIFICIAL_BLOOD.Data then
			if Player:GetData()['usedBlood'] then
				Player.Damage = Player.Damage + CustomStatups.SACBLOOD_DMG * (CustomData.Cards.SACRIFICIAL_BLOOD.NumUses - Step / 50)
			end
		end
		
		if Player:HasTrinket(CustomTrinkets.MAGIC_SWORD) then
			Player.Damage = Player.Damage * CustomStatups.MAGICSWORD_DMG_MUL * Player:GetTrinketMultiplier(CustomTrinkets.MAGIC_SWORD)
		end
		
		if Player:HasTrinket(CustomTrinkets.BONE_MEAL) then
			Player.Damage = Player.Damage * CustomStatups.BONEMEAL_DMG_MUL ^ (CustomData.CustomTrinkets.BONE_MEAL.Levels * Player:GetTrinketMultiplier(CustomTrinkets.BONE_MEAL))
		end
		
		if CustomData and CustomData.Items.CHEESE_GRATER.NumUses then
			if Player:GetData()['graterUsed'] == true then
				Player.Damage = Player.Damage + CustomData.Items.CHEESE_GRATER.NumUses * CustomStatups.GRATER_DMG
			end
		end
		
		if Player:HasCollectible(CustomCollectibles.BLESS_OF_THE_DEAD) and CustomData then
			Player.Damage = Player.Damage + CustomData.Items.BLESS_OF_THE_DEAD.NumUses * CustomStatups.BLESS_DMG
		end
		
		if CustomData then
			if Player:GetData()['GetYumDamage'] then
				Player.Damage = Player.Damage + CustomData.CustomPills.YUM.NumDamage * CustomStatups.YUM_DAMAGE
			end
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.Damage = Player.Damage + CustomStatups.MOTHERSLOVE_DMG * CustomData.Items.MOTHERS_LOVE.NumStats
		end
		
		if CustomData and Player:GetData()['usedDemonForm'] then 
			Player.Damage = Player.Damage + CustomData.Cards.DEMON_FORM.NumUses * CustomStatups.DEMONFORM_DAMAGE
		end
		
		if Player:GetData()['NumPickedBenightedHearts'] then
			Player.Damage = Player.Damage + Player:GetData()['NumPickedBenightedHearts'] * 0.1
		end
	end
	
	if Flag == CacheFlag.CACHE_FIREDELAY then
		if Player:HasCollectible(CustomCollectibles.ORDINARY_LIFE) then
			Player.MaxFireDelay = Player.MaxFireDelay * CustomStatups.ORDLIFE_TEARS_MUL
		end
		
		if Player:HasCollectible(CustomCollectibles.GUSTY_BLOOD) then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomStatups.GUSTYBLOOD_TEARS * CustomData.Items.GUSTY_BLOOD.CurrentTears^2 / (CustomData.Items.GUSTY_BLOOD.CurrentTears + 1))
		end
		
		if CustomData then
			if Player:GetData()['GetYumTears'] then
				Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomData.CustomPills.YUM.NumTears * CustomStatups.YUM_TEARS)
			end
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomStatups.MOTHERSLOVE_TEARS * CustomData.Items.MOTHERS_LOVE.NumStats)
		end
	end
	
	if Flag == CacheFlag.CACHE_TEARFLAG then
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART) then
			Player.TearFlags = Player.TearFlags | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL
		end
		
		if Player:HasTrinket(CustomTrinkets.TORN_PAGE) and Player:GetData()['enhancedBoB'] then
			Player.TearFlags = Player.TearFlags | TearFlags.TEAR_BELIAL | TearFlags.TEAR_PIERCING
		end
		
		if Player:HasCollectible(CustomCollectibles.ANGELS_WINGS) then
			Player.TearFlags = Player.TearFlags | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SLOW
		end
	end
	
	if Flag == CacheFlag.CACHE_SHOTSPEED then
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART)  then
			Player.ShotSpeed = Player.ShotSpeed + CustomStatups.SINNERSHEART_SHSP
		end
	end
	
	if Flag == CacheFlag.CACHE_RANGE then 
		-- Range currently not functioning, blame Edmund
		-- it's working now, yo!
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART)  then
			Player.TearRange = Player.TearRange + CustomStatups.SINNERSHEART_RANGE * 40
		end
		
		if CustomData then
			if Player:GetData()['GetYumRange'] then
				Player.TearRange = Player.TearRange + CustomData.CustomPills.YUM.NumRange * CustomStatups.YUM_RANGE * 40
			end
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.TearRange = Player.TearRange + CustomStatups.MOTHERSLOVE_RANGE * CustomData.Items.MOTHERS_LOVE.NumStats * 40
		end
	end
	
	if Flag == CacheFlag.CACHE_FAMILIARS then
		Player:CheckFamiliar(CustomFamiliars.BAG_O_TRASH, getTrueFamiliarNum(Player, CustomCollectibles.BAG_O_TRASH), Player:GetCollectibleRNG(CustomCollectibles.BAG_O_TRASH))
		Player:CheckFamiliar(CustomFamiliars.CHERUBIM, getTrueFamiliarNum(Player, CustomCollectibles.CHERUBIM), Player:GetCollectibleRNG(CustomCollectibles.CHERUBIM))
		Player:CheckFamiliar(CustomFamiliars.TOY_TANK_1, getTrueFamiliarNum(Player, CustomCollectibles.TANK_BOYS), Player:GetCollectibleRNG(CustomCollectibles.TANK_BOYS))
		Player:CheckFamiliar(CustomFamiliars.TOY_TANK_2, getTrueFamiliarNum(Player, CustomCollectibles.TANK_BOYS), Player:GetCollectibleRNG(CustomCollectibles.TANK_BOYS))
		if not Player:GetData()['fightingSiblings'] then
			Player:CheckFamiliar(CustomFamiliars.SIBLING_1, getTrueFamiliarNum(Player, CustomCollectibles.SIBLING_RIVALRY), Player:GetCollectibleRNG(CustomCollectibles.SIBLING_RIVALRY))
			Player:CheckFamiliar(CustomFamiliars.SIBLING_2, getTrueFamiliarNum(Player, CustomCollectibles.SIBLING_RIVALRY), Player:GetCollectibleRNG(CustomCollectibles.SIBLING_RIVALRY))
		else
			Player:CheckFamiliar(CustomFamiliars.FIGHTING_SIBLINGS, getTrueFamiliarNum(Player, CustomCollectibles.SIBLING_RIVALRY), Player:GetCollectibleRNG(CustomCollectibles.SIBLING_RIVALRY))
		end
		Player:CheckFamiliar(CustomFamiliars.REJECTION_FETUS, getTrueFamiliarNum(Player, CustomCollectibles.REJECTION_P), Player:GetCollectibleRNG(CustomCollectibles.REJECTION_P))
	end
	
	if Flag == CacheFlag.CACHE_LUCK then
		if Player:GetData()['usedLoadedDice'] then
			Player.Luck = Player.Luck + CustomStatups.LOADED_DICE_LUCK
		end
		
		if CustomData then
			if Player:GetData()['GetYumLuck'] then
				Player.Luck = Player.Luck + CustomData.CustomPills.YUM.NumLuck * CustomStatups.YUM_LUCK
			end
		end	
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.Luck = Player.Luck + CustomStatups.MOTHERSLOVE_LUCK * CustomData.Items.MOTHERS_LOVE.NumStats
		end
	end
	
	if Flag == CacheFlag.CACHE_SPEED then
		if Player:HasCollectible(CustomCollectibles.GUSTY_BLOOD) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.GUSTYBLOOD_SPEED * CustomData.Items.GUSTY_BLOOD.CurrentSpeed^2 / (CustomData.Items.GUSTY_BLOOD.CurrentSpeed + 1)
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.MOTHERSLOVE_SPEED * CustomData.Items.MOTHERS_LOVE.NumStats
		end
		
		if Player:HasCollectible(CustomCollectibles.NERVE_PINCH) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.NERVEPINCH_SPEED * CustomData.Items.NERVE_PINCH.NumTriggers
		end
		if Player:HasCollectible(CustomCollectibles.HAND_ME_DOWNS) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.HANDMEDOWNS_SPEED
		end
	end
	
	if Flag == CacheFlag.CACHE_FLYING then
		if Player:GetData()['catchingBird'] then
			Player.CanFly = true
		end
	end
	
	if Flag == CacheFlag.CACHE_TEARCOLOR then
		if Player:HasCollectible(CustomCollectibles.CROSS_OF_CHAOS) then
			Player.TearColor = Color(0.15, 0.15, 0.15, 1, 0, 0, 0)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, rplus.UpdateStats)

						-- MC_FAMILIAR_INIT --										
						----------------------
function rplus:FamiliarInit(Familiar)
	local fSprite = Familiar:GetSprite()
	
	if Familiar.Variant == CustomFamiliars.BAG_O_TRASH then
		CustomData.Items.BAG_O_TRASH.Levels = 1
		Familiar:AddToFollowers()
		Familiar.IsFollower = true
	end
	
	if Familiar.Variant == CustomFamiliars.CHERUBIM then
		Familiar:AddToFollowers()
		Familiar.IsFollower = true
	end
	
	if Familiar.Variant == CustomFamiliars.REJECTION_FETUS then
		Familiar:AddToFollowers()
		Familiar.IsFollower = true
		Familiar:GetSprite().PlaybackSpeed = 0.5
	end
	
	if Familiar.Variant == CustomFamiliars.TOY_TANK_1 or Familiar.Variant == CustomFamiliars.TOY_TANK_2 then
		Familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		Familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		if Familiar.Variant == CustomFamiliars.TOY_TANK_1 then
			Familiar:GetData().Data = {lineOfSightDist = 450, lineOfSightAngle = 40, tankVelocityMul = 3.5, 
				tankAttackBuffer = 8, currBuffer = 0, projectileVelocityMul = 20, newRoomAttackHold = 0,
				newRoomCurrHold = 0}
		else
			Familiar:GetData().Data = {lineOfSightDist = 300, lineOfSightAngle = 10, tankVelocityMul = 1.75, 
				tankAttackBuffer = 90, currBuffer = 0, projectileVelocityMul = 10, newRoomAttackHold = 60,
				newRoomCurrHold = 0}
		end		
	end
	
	if Familiar.Variant == CustomFamiliars.SIBLING_1 or Familiar.Variant == CustomFamiliars.SIBLING_2 or Familiar.Variant == CustomFamiliars.FIGHTING_SIBLINGS then
		Familiar:AddToOrbit(25)
		fSprite:Play("Idle")
	end
end
rplus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, rplus.FamiliarInit)

						-- MC_FAMILIAR_UPDATE --	 								
						------------------------
function rplus:FamiliarUpdate(Familiar)
	if Familiar.Variant == CustomFamiliars.BAG_O_TRASH then 
		Familiar:FollowParent()
		if Familiar:GetSprite():IsFinished("Spawn") then
			Familiar:GetSprite().PlaybackSpeed = 1.0
			Familiar:GetSprite():Play("FloatDown")
		end
		
		if Familiar.RoomClearCount == 1 then
			local NumFlies = math.random(math.ceil(CustomData.Items.BAG_O_TRASH.Levels * 1.5))
			
			Familiar:GetSprite().PlaybackSpeed = 0.5
			Familiar:GetSprite():Play("Spawn")
			for _ = 1, (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS, true) and NumFlies + math.random(2) or NumFlies) do 
				Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, 0, Familiar.Position, Vector.Zero, nil) 
			end
			
			if Sewn_API then
				if Sewn_API:GetLevel(Familiar:GetData()) == 2 then
					local NumSpiders = math.random(math.ceil(CustomData.Items.BAG_O_TRASH.Levels * 1.5))
					for _ = 1, (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS, true) and NumSpiders + math.random(2) or NumSpiders) do 
						Isaac.Spawn(3, FamiliarVariant.BLUE_SPIDER, 0, Familiar.Position, Vector.Zero, nil) 
					end
				end
			end
			
			Familiar.RoomClearCount = 0
		end
	end
	
	if Familiar.Variant == CustomFamiliars.CHERUBIM then
		Familiar:FollowParent()
		local Sprite = Familiar:GetSprite()
		local player = Familiar.Player
		local TearVector
		
		if player:GetFireDirection() == Direction.NO_DIRECTION then
			Sprite:Play(DIRECTION_FLOAT_ANIM[player:GetMovementDirection()], false)
		else
			TearVector = DIRECTION_VECTOR[player:GetFireDirection()]
			Sprite:Play(DIRECTION_SHOOT_ANIM[player:GetFireDirection()], false)
		end
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and #Isaac.FindByType(1000, EffectVariant.TARGET, -1, false, true) > 0 then
			TearVector = (Isaac.FindByType(1000, EffectVariant.TARGET, -1, false, true)[1].Position - Familiar.Position):Normalized()
			Sprite:Play(DIRECTION_SHOOT_ANIM[player:GetFireDirection()], false)
		end
		
		if Familiar.FireCooldown <= 0 and TearVector then
			local Tear = Familiar:FireProjectile(TearVector):ToTear()
			Tear.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 10 or 5)
			Tear.TearFlags = TearFlags.TEAR_GLOW | TearFlags.TEAR_HOMING
			
			if Sewn_API then
				local crownTier = Sewn_API:GetLevel(Familiar:GetData())
                if crownTier == 1 then
					Tear.CollisionDamage = Tear.CollisionDamage * 1.3
					Tear.Scale = Tear.Scale * 1.2
				end
				if crownTier == 2 then
					Tear:ChangeVariant(TearVariant.EYE)
					Tear.TearFlags = TearFlags.TEAR_GLOW | TearFlags.TEAR_HOMING | TearFlags.TEAR_POP
				end
			end
			
			Tear:Update()

			if player:HasTrinket(Isaac.GetTrinketIdByName("Forgotten Lullaby")) then
				Familiar.FireCooldown = 12
			else
				Familiar.FireCooldown = 18
			end
		end

		Familiar.FireCooldown = Familiar.FireCooldown - 1
	end
	
	if Familiar.Variant == CustomFamiliars.REJECTION_FETUS then 
		Familiar:FollowParent()
		Familiar:GetSprite():Play("Rotate")
	end
	
	if Familiar.Variant == CustomFamiliars.ENRAGED_SOUL then
		if CustomData.Items.ENRAGED_SOUL.AttachedEnemy then
			if CustomData.Items.ENRAGED_SOUL.AttachedEnemy:IsActiveEnemy() and AttachFrames >= 0 then
				Familiar.Position = CustomData.Items.ENRAGED_SOUL.AttachedEnemy.Position
				AttachFrames = AttachFrames - 1
			else 	
				Familiar:Kill()
				CustomData.Items.ENRAGED_SOUL.AttachedEnemy = nil
			end
		end
	end
	
	if Familiar.Variant == CustomFamiliars.TOY_TANK_1 or Familiar.Variant == CustomFamiliars.TOY_TANK_2 then 
		-- moving around (BASEMENT DRIFT YOOO)
		-- change direction naturally; they change direction when colliding with grid automatically
		if game:GetFrameCount() % 48 == 0 then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[math.random(#DIRECTION_VECTOR_SIMPLIFIED)] * Familiar:GetData().Data.tankVelocityMul
		end
		
		-- correct the velocity when colliding with grid so that the tanks don't move diagonally
		local TX = Familiar.Velocity.X
		local TY = Familiar.Velocity.Y
		if TY > 0 and TX <= TY and TX >= -TY then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[1] * Familiar:GetData().Data.tankVelocityMul
		elseif TX > 0 and TY < TX and TY > -TX then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[4] * Familiar:GetData().Data.tankVelocityMul
		elseif TX <= 0 and TY < -TX and TY > TX then
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[2] * Familiar:GetData().Data.tankVelocityMul
		else
			Familiar.Velocity = DIRECTION_VECTOR_SIMPLIFIED[3] * Familiar:GetData().Data.tankVelocityMul
		end
		
		local tankSprite = Familiar:GetSprite()
		if Familiar.Velocity.X < -0.1 and math.abs(Familiar.Velocity.Y) < 0.1  then tankSprite:Play("MoveLeft") 
		elseif Familiar.Velocity.Y < -0.1 and math.abs(Familiar.Velocity.X) < 0.1 then tankSprite:Play("MoveUp") 
		elseif Familiar.Velocity.X > 0.1 and math.abs(Familiar.Velocity.Y) < 0.1 then tankSprite:Play("MoveRight") 
		else tankSprite:Play("MoveDown") end
		
		-- shooting at enemies
		for _, enemy in pairs(Isaac.FindInRadius(Familiar.Position, Familiar:GetData().Data.lineOfSightDist, EntityPartition.ENEMY)) do
			if enemy.Type ~= EntityType.ENTITY_SHOPKEEPER and enemy.Type ~= EntityType.ENTITY_FIREPLACE 
			and enemy:IsVulnerableEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_CHARM) then
				local curVel = Familiar.Velocity:Normalized()
				local posDiff = (enemy.Position - Familiar.Position):Normalized()
				
				if game:GetRoom():CheckLine(enemy.Position, Familiar.Position, 3, 0, false, false) and 
				math.abs(curVel:GetAngleDegrees() - posDiff:GetAngleDegrees()) < Familiar:GetData().Data.lineOfSightAngle then
					if game:GetFrameCount() > Familiar:GetData().Data.currBuffer + Familiar:GetData().Data.tankAttackBuffer 
					and game:GetFrameCount() > Familiar:GetData().Data.newRoomCurrHold + Familiar:GetData().Data.newRoomAttackHold then
						if Familiar.Variant == CustomFamiliars.TOY_TANK_1 then
							local tankBullet = Isaac.Spawn(2, TearVariant.METALLIC, 0, Familiar.Position, posDiff * Familiar:GetData().Data.projectileVelocityMul, nil):ToTear()
							if Sewn_API then
								if Sewn_API:GetLevel(Familiar:GetData()) >= 1 then
									tankBullet:AddTearFlags(TearFlags.TEAR_HOMING)
								end
								if Sewn_API:GetLevel(Familiar:GetData()) == 2 then
									for _, familiarInRoom in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, CustomFamiliars.TOY_TANK_2, -1, false, false)) do
										local tankLaser = EntityLaser.ShootAngle(2,	familiarInRoom.Position, (enemy.Position - familiarInRoom.Position):Normalized():GetAngleDegrees(), 7, Vector(0,0), familiarInRoom)
										tankLaser.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 7 or 3.5)
									end
								end
							end
								tankBullet.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 7 or 3.5)
						elseif Familiar.Variant == CustomFamiliars.TOY_TANK_2 then
							local tankRocket = Isaac.Spawn(4, 19, 0, Familiar.Position, Vector.Zero, nil):ToBomb()
							tankRocket.SpriteScale = Vector(0.6, 0.6)
							tankRocket:GetData().forcedRocketTargetVel = curVel * Familiar:GetData().Data.projectileVelocityMul
							tankRocket.ExplosionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 70 or 35)
						end
						Familiar:GetData().Data.currBuffer = game:GetFrameCount()
					end
				end
			end
		end
	end
	
	if Familiar.Variant == CustomFamiliars.SIBLING_1 or Familiar.Variant == CustomFamiliars.SIBLING_2 or Familiar.Variant == CustomFamiliars.FIGHTING_SIBLINGS then
		Familiar.Velocity = Familiar:GetOrbitPosition(Familiar.Player.Position + Familiar.Player.Velocity) - Familiar.Position
	
		if Familiar.Variant == CustomFamiliars.SIBLING_1 or Familiar.Variant == CustomFamiliars.SIBLING_2 then
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
	
	if Familiar.IsFollower and Familiar.Player:GetData().RejectionUsed then
		Familiar:Remove()
	end
end
rplus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, rplus.FamiliarUpdate)

						-- MC_POST_BOMB_UPDATE --									
						-------------------------
function rplus:BombUpdate(Bomb)
	if Bomb.SpawnerEntity and Bomb.SpawnerEntity:ToPlayer() then
		local player = Bomb.SpawnerEntity:ToPlayer()
		
		if player:HasCollectible(CustomCollectibles.RED_BOMBER) 
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

						-- MC_POST_KNIFE_UPDATE --									
						--------------------------
function rplus:KnifeUpdate(Knife)
	if Knife.FrameCount == 1 then
		local player = Knife.Parent:ToPlayer() or Knife.SpawnerEntity:ToPlayer()
		
		if player then 
			if player:HasCollectible(CustomCollectibles.CEREMONIAL_BLADE) then
				Knife:GetSprite():ReplaceSpritesheet(0, "gfx/ceremonial_knife.png")
				Knife:GetSprite():LoadGraphics()
				Knife:GetData().IsCeremonial = true
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, rplus.KnifeUpdate)

						-- MC_PRE_FAMILIAR_COLLISION --									
						-------------------------------
function rplus:FamiliarCollision(Familiar, Collider, _)
	if Familiar.Variant == CustomFamiliars.CHERRY then
		if Collider:IsActiveEnemy(true) and not Collider:IsBoss() and game:GetFrameCount() % 10 == 0 then
			game:CharmFart(Familiar.Position, 10.0, Familiar)
			sfx:Play(SoundEffect.SOUND_FART, 1, 2, false, 1, 0)
		end
	end	
	
	if Familiar.Variant == CustomFamiliars.BIRD then
		if Collider.Type == 1 then
			for i = 0, game:GetNumPlayers() - 1 do
				local player = Isaac.GetPlayer(i)
				
				if player:GetData()['catchingBird'] then
					sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, 1, 0)
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, Familiar.Position, Vector.Zero, nil)
					Familiar:Remove()
					player.Position = DiePos
					player:TryRemoveNullCostume(Costumes.BIRD_OF_HOPE)
					CustomData.Items.BIRD_OF_HOPE.BirdCaught = true
					GiveRevivalIVFrames(player)
					player:GetData()['catchingBird'] = nil
					player:AddCacheFlags(CacheFlag.CACHE_FLYING)
					player:EvaluateItems()
				end
			end
		end
	end	
	
	if Familiar.Variant == CustomFamiliars.ENRAGED_SOUL then	
		if Collider:IsActiveEnemy(true) and not Collider:HasEntityFlags(EntityFlag.FLAG_CHARM) and not CustomData.Items.ENRAGED_SOUL.AttachedEnemy then
			Familiar.Velocity = Vector.Zero
			CustomData.Items.ENRAGED_SOUL.AttachedEnemy = Collider
			AttachFrames = ENRAGED_SOUL_COOLDOWN / 2
			Familiar:GetSprite():Play("Idle", true)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, rplus.FamiliarCollision)

						-- MC_PRE_PROJECTILE_COLLISION --									
						---------------------------------
function rplus:ProjectileCollision(Projectile, Collider, _)
	if Collider.Variant == CustomFamiliars.BAG_O_TRASH then
		Projectile:Remove()
		if math.random(100) <= TRASHBAG_BREAK_CHANCE then
			sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 1, false, 1, 0)
			if Sewn_API then
				if Sewn_API:GetLevel(Collider:ToFamiliar():GetData()) < 1 then
					Isaac.GetPlayer(0):RemoveCollectible(CustomCollectibles.BAG_O_TRASH)
					if math.random(100) <= 66 then
						Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_BREAKFAST, Collider.Position, Vector.Zero, nil)
					else
						Isaac.Spawn(5, 350, CustomTrinkets.NIGHT_SOIL, Collider.Position, Vector.Zero, nil)
					end
				end
			else
				Isaac.GetPlayer(0):RemoveCollectible(CustomCollectibles.BAG_O_TRASH)
				if math.random(100) <= 66 then
					Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_BREAKFAST, Collider.Position, Vector.Zero, nil)
				else
					Isaac.Spawn(5, 350, CustomTrinkets.NIGHT_SOIL, Collider.Position, Vector.Zero, nil)
				end
			end
		end
	end
	
	if Collider.Variant == CustomFamiliars.SIBLING_1 or
	Collider.Variant == CustomFamiliars.SIBLING_2 or 
	Collider.Variant == CustomFamiliars.FIGHTING_SIBLINGS then
		Projectile:Remove()
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, rplus.ProjectileCollision)

						-- MC_PRE_PLAYER_COLLISION --										
						-----------------------------
function rplus:playerCollision(Player, Collider, _)
	if Player:HasTrinket(CustomTrinkets.TRICK_PENNY) and math.random(100) <= TRICKPENNY_CHANCE * Player:GetTrinketMultiplier(CustomTrinkets.TRICK_PENNY) then
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
	
	if Player:HasCollectible(CustomCollectibles.CEILING_WITH_THE_STARS) and Collider.Type == 5 and Collider.Variant == 380 and not CustomData.Items.CEILING_WITH_THE_STARS.SleptInBed then
		CustomData.Items.CEILING_WITH_THE_STARS.SleptInBed = true
		for i = 1, 2 do
			repeat 
				newID = GetUnlockedVanillaCollectible()
			until Isaac.GetItemConfig():GetCollectible(newID).Type % 3 == 1
			Player:AddItemWisp(newID, Player.Position, true)
		end
	end
	
	if Collider.Type == 6 and Collider.Variant == CustomPickups.SLOT_STARGAZER and Player:GetNumCoins() >= 5 
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
	local NoOptionsQQQ = true 	-- does any player have Options? item
	
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
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_OPTIONS) then
			NoOptionsQQQ = false
		end
		
		if player:HasCollectible(CustomCollectibles.RED_KING) then
			if room:GetType() == RoomType.ROOM_BOSS 
			and level:GetStage() < 9 then
				if CustomData.Items.RED_KING.IsInRedKingRoom then
					if player:HasCollectible(CollectibleType.COLLECTIBLE_THERES_OPTIONS) then
						Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Vector(360, 360), Vector.Zero, nil):ToPickup().OptionsPickupIndex = 7
						Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Vector(280, 360), Vector.Zero, nil):ToPickup().OptionsPickupIndex = 7
					else
						Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Vector(320, 360), Vector.Zero, nil)
					end
					CustomData.Items.RED_KING.DefeatedRedKingBoss = true
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
			Isaac.Spawn(5, CustomPickups.SCARLET_CHEST, 0, game:GetRoom():FindFreePickupSpawnPosition(Pos, 0, true, false), Vector.Zero, nil)
			sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			return true
		end
		
		if CustomData and CustomData.TaintedHearts.SOILED > 0 then for i = 1, CustomData.TaintedHearts.SOILED do
			Isaac.Spawn(3, 201, -1, player.Position, Vector.FromAngle(math.random(360)) * 3, nil) 	-- spawn dips for every half of soiled heart
			Isaac.FindByType(3, FamiliarVariant.BLUE_FLY, 0, false, false)[1]:Remove()
			Isaac.FindByType(3, FamiliarVariant.BLUE_FLY, 0, false, false)[2]:Remove() 				-- remove two flies that rotten hearts would've spawned
		end end
	end
	
	if CustomData and math.random(100) < JACK_CHANCE and CustomData.Cards.JACK 
	and NoOptionsQQQ and room:GetType() ~= RoomType.ROOM_BOSS and room:GetType() ~= RoomType.ROOM_BOSSRUSH then
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
end
rplus:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, rplus.PickupAwardSpawn)

						-- MC_GET_PILL_EFFECT --							
						------------------------
function rplus:ChangePillEffects(pillEffect, pillColor)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_PHD) then
			if pillEffect == CustomPills.PHANTOM_PAINS then
				return game:GetItemPool():GetPillEffect(1, player)
			end
		end
		
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD) then
			if pillEffect == CustomPills.YUM or pillEffect == CustomPills.YUCK
			or pillEffect == CustomPills.ESTROGEN then
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
		for _, slot in pairs(Isaac.FindByType(6, CustomPickups.SLOT_STARGAZER, -1, false, true)) do
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
	EID:addCollectible(CustomCollectibles.ORDINARY_LIFE, "{{ArrowUp}} Tears up #Spawns an additional Mom/Dad related item in Treasure rooms alongside the presented items; only one item can be taken")	
	EID:addCollectible(CustomCollectibles.COOKIE_CUTTER, "Gives you one {{Heart}} heart container and one broken heart #{{Warning}} Having 12 broken hearts kills you!")
	EID:addCollectible(CustomCollectibles.SINNERS_HEART, "+2 black hearts #{{ArrowUp}} Damage +2 then x1.5 #{{ArrowUp}} Grants +2 range and -0.2 shotspeed #Grants spectral and piercing tears")
	EID:addCollectible(CustomCollectibles.RUBIKS_CUBR, "After each use, has a 5% (100% on 20-th use) chance to be 'solved', removed from the player and be replaced with a Magic Cube item")
	EID:addCollectible(CustomCollectibles.MAGIC_CUBE, "Rerolls item pedestals #Rerolled items can be drawn from any item pool")
	EID:addCollectible(CustomCollectibles.MAGIC_PEN, "Double tap shooting button to spew a line of {{ColorRainbow}}rainbow{{CR}} creep in the direction you're firing #Random permanent status effects is applied to enemies walking over that creep #{{Warning}} Has a 4 seconds cooldown")
	EID:addCollectible(CustomCollectibles.MARK_OF_CAIN, "On death, if you have any familiars, removes them instead and revives you #On revival, you keep your heart containers, gain +" .. tostring(CustomStatups.MARKCAIN_DMG) .. " DMG for each consumed familiar and gain invincibility #{{Warning}} Works only once!")
	EID:assignTransformation("collectible", CustomCollectibles.MARK_OF_CAIN, "9")
	EID:addCollectible(CustomCollectibles.TEMPER_TANTRUM, "25% chance to enter Berserk state when taking damage #While in this state, every enemy damaged has a 10% chance to be erased for the rest of the run")
	EID:addCollectible(CustomCollectibles.BAG_O_TRASH, "A familiar that creates blue flies upon clearing a room #Blocks enemy projectiles, and after blocking it has a chance to be destroyed and drop Breakfast or Nightsoil trinket #The more floors it is not destroyed, the more flies it spawns")
	EID:addCollectible(CustomCollectibles.CHERUBIM, "A familiar that rapidly shoots tears with Godhead aura")
	EID:assignTransformation("collectible", CustomCollectibles.CHERUBIM, "4,10")
	EID:addCollectible(CustomCollectibles.CHERRY_FRIENDS, "Killing an enemy has a 20% chance to drop cherry familiar on the ground #Those cherries emit a charming fart when an enemy walks over them, and drop half a heart when a room is cleared")
	EID:addCollectible(CustomCollectibles.BLACK_DOLL, "Upon entering a new room, all enemies will be split in pairs. Dealing damage to one enemy in each pair will deal 60% of that damage to another enemy in that pair")
	EID:addCollectible(CustomCollectibles.BIRD_OF_HOPE, "Upon dying you turn into invincible ghost and a bird flies out of room center in a random direction. Catching the bird in 5 seconds will save you and get you back to your death spot, otherwise you will die #{{Warning}} Every time you die, the bird will fly faster and faster, making it harder to catch her")
	EID:addCollectible(CustomCollectibles.ENRAGED_SOUL, "Double tap shooting button to launch a ghost familiar in the direction you are firing #The ghost will latch onto the first enemy it collides with, dealing damage over time for 7 seconds or until that enemy is killed #The ghost's damage per hit starts at 7 and increases each floor #The ghost can latch onto bosses aswell #{{Warning}} Has a 7 seconds cooldown")
	EID:addCollectible(CustomCollectibles.CEREMONIAL_BLADE, "When shooting, 7% chance to launch a piercing dagger that does no damage, but inflicts bleed on enemies #All enemies that die while bleeding will drop Sacrificial Blood Consumable that gives you temporary DMG up")
	EID:addCollectible(CustomCollectibles.CEILING_WITH_THE_STARS, "Grants you two Lemegeton wisps at the beginning of each floor and when sleeping in bed")
	EID:addCollectible(CustomCollectibles.QUASAR, "Consumes all item pedestals in the room and gives you 3 Lemegeton wisps for each item consumed")
	EID:addCollectible(CustomCollectibles.TWO_PLUS_ONE, "Every third shop item on the current floor will cost 1 {{Coin}} penny #Buying two items with hearts in one room makes all other items free")
	EID:addCollectible(CustomCollectibles.RED_MAP, "Reveals location of Ultra Secret Room on all subsequent floors #Any trinket left in a boss or treasure room will turn into Cracked Key, unless this is your first visit in such room")
	EID:addCollectible(CustomCollectibles.CHEESE_GRATER, "Removes one red heart container and gives you {{ArrowUp}} +" .. tostring(CustomStatups.GRATER_DMG) .. " Damage up and 3 Minisaacs")
	EID:addCollectible(CustomCollectibles.DNA_REDACTOR, "Pills now have additional effects based on their color")
	EID:addCollectible(CustomCollectibles.TOWER_OF_BABEL, "Destroys all obstacles in the current room and applies confusion to enemies in small radius around you #Also blows the doors open and opens secret room entrances")
	EID:addCollectible(CustomCollectibles.BLESS_OF_THE_DEAD, "Prevents curses from appearing for the rest of the run #Preventing a curse grants you {{ArrowUp}} +" .. tostring(CustomStatups.BLESS_DMG) .. " damage up")
	EID:addCollectible(CustomCollectibles.TANK_BOYS, "Spawns 2 Toy Tanks that roam around the room and attack enemies that are in their line of sight #Green tank: rapidly shoots bullets at enemies from a further distance and moves more quickly #Red tank: shoots rockets at enemies at a close range, moves slower")
	EID:addCollectible(CustomCollectibles.GUSTY_BLOOD, "Killing enemies grants you {{ArrowUp}} tears and speed up #The bonus is reset when entering a new room")
	EID:addCollectible(CustomCollectibles.RED_BOMBER, "+5 bombs #Grants explosion immunity #Allows you to throw your bombs instead of placing them on the ground")
	EID:addCollectible(CustomCollectibles.MOTHERS_LOVE, "Grants you stat boosts for each familiar you own #Some familiars grant greater stat boosts, and some do not grant them at all (e.g. blue flies, dips or Isaac's body parts)")
	EID:addCollectible(CustomCollectibles.CAT_IN_A_BOX, "When entering a room with enemies, their health is halved for the first 3 seconds, and then restored back to full #Doesn't work on bosses or minibosses")
	EID:addCollectible(CustomCollectibles.BOOK_OF_GENESIS, "Removes a random item and spawns 3 items of the same quality #Only one item can be taken #Can't remove or spawn quest items")
	EID:assignTransformation("collectible", CustomCollectibles.BOOK_OF_GENESIS, "12")
	EID:addCollectible(CustomCollectibles.SCALPEL, "Makes you shoot tears in the opposite direction #From the front, you will frequently shoot bloody tears that deal x0.66 of your damage #All other weapon types will still be fired from the front as well")
	EID:addCollectible(CustomCollectibles.KEEPERS_PENNY, "Spawns a golden penny upon entering a new floor #Shops will now sell 1-4 additional items that are drawn from shop, treasure or boss itempools #If the shop is a Greed fight, it instead spawns 3-4 items when the miniboss dies")
	EID:addCollectible(CustomCollectibles.NERVE_PINCH, "Shooting or moving for 8 seconds will trigger a nerve pinch #{{ArrowDown}} You take fake damage and gain a permanent " .. tostring(CustomStatups.NERVEPINCH_SPEED) .. " speed down when that happens #{{ArrowUp}} However, there is a 75% chance to activate your active item for free, even if it's uncharged #One-time use and infinite use actives cannot be used that way")
	EID:addCollectible(CustomCollectibles.BLOOD_VESSELS[1], "Taking damage doesn't actually hurt the player, instead filling the blood vessel #This can be repeated 6 times until the vessel is full #Once it's full, using it or taking damage will empty it and deal 3 and 3.5 hearts of damage to the player, respectively")
	EID:addCollectible(CustomCollectibles.SIBLING_RIVALRY, "Orbital that switches between 2 different states every 15 seconds: #Two orbitals that quickly rotate around Isaac #One orbital that rotates slower and closer to Isaac, and periodically shoots teeth in random directions and spawns blood creep underneath it #{{Warning}} All orbitals block enemy shots and do contact damage")
	EID:addCollectible(CustomCollectibles.RED_KING, "After defeating a boss, red crawlspace will appear in a middle of a room #Entering the crawlspace brings you to another bossfight of high difficulty #Victory rewards you a red item (from Ultra secret room pool)")
	EID:addCollectible(CustomCollectibles.STARGAZERS_HAT, "Summons the Stargazer beggar #Can only be charged with soul hearts, similar to Alabaster Box #2 soul hearts needed for full charge")
	EID:addCollectible(CustomCollectibles.BOTTOMLESS_BAG, "Upon use, holds the bag in the air #For 4 seconds, all nearby projectiles are sucked into the bag #Hold the shooting button to release all sucked projecties as homing tears in the matching direction after 4 seconds")
	EID:addCollectible(CustomCollectibles.CROSS_OF_CHAOS, "Enemies that come close to you become crippled; your tears can also cripple them #Crippled enemies lose their speed overtime, and die afer 16 seconds of losing it #When crippled enemies die, they release a fountain of slowing black tears")
	EID:assignTransformation("collectible", CustomCollectibles.CROSS_OF_CHAOS, "9")
	EID:addCollectible(CustomCollectibles.REJECTION, "On use, consume all your follower familiars and throw them as big piercing poisonous gut ball in your firing direction #Damage formula: your dmg * 4 * number of consumed familiars #Passively grants a familiar that doesn't shoot tears, but deals 2.5 contact damage to enemies")
	EID:addCollectible(CustomCollectibles.AUCTION_GAVEL, "Spawns an item from the room's pool for sale #Its price will change rougly 5 times a second #The price is random, but generally increases over time until it reaches $99 #If you leave and re-enter the room, the item disappears")
	EID:addCollectible(CustomCollectibles.SOUL_BOND, "Chain yourself to a random enemy with an astral chain and freeze them #The chain deals contact damage to enemies #Going too far away from chained enemy will break the chain #Chained enemies have a 50% chance to drop half a soul heart when killed")
	EID:addCollectible(CustomCollectibles.HAND_ME_DOWNS, "{{ArrowUp}} +0.2 Speed up #In your next run in starting room on stage where this run ended spawns 3 items from this run #Can't spawn story items or itself")	
	
	EID:addTrinket(CustomTrinkets.BASEMENT_KEY, "While held, every Golden Chest has a 12.5% chance to be replaced with Old Chest")
	EID:addTrinket(CustomTrinkets.KEY_TO_THE_HEART, "While held, every enemy has a chance to drop Flesh Chest upon death #Flesh Chests contain 1-4 {{Heart}} heart/{{Pill}} pills or a random body-related item")
	EID:addTrinket(CustomTrinkets.JUDAS_KISS, "Enemies touching you become targeted by other enemies (effect similar to Rotten Tomato)")
	EID:addTrinket(CustomTrinkets.TRICK_PENNY, "Using coin, bomb or key on slots, beggars or locked chests has a 17% chance to not subtract it from your inventory count")
	EID:addTrinket(CustomTrinkets.SLEIGHT_OF_HAND, "Upon spawning, every coin has a 20% chance to be upgraded to a higher value: #penny -> doublepack pennies -> sticky nickel -> nickel -> dime -> lucky penny -> golden penny")
	EID:addTrinket(CustomTrinkets.GREEDS_HEART, "Gives you one empty coin heart #It is depleted before any of your normal hearts and can only be refilled by directly picking up money")
	EID:addTrinket(CustomTrinkets.ANGELS_CROWN, "All new treasure rooms will have an angel item for sale instead of a normal item #Angels spawned from statues will not drop Key Pieces!")
	EID:addTrinket(CustomTrinkets.MAGIC_SWORD, "{{ArrowUp}} x2 DMG up while held #Breaks when you take damage #{{ArrowUp}} Having Duct Tape prevents it from breaking")
	EID:addTrinket(CustomTrinkets.WAIT_NO, "Does nothing, it's broken")
	EID:addTrinket(CustomTrinkets.EDENS_LOCK, "Upon taking damage, one of your items rerolls into another random item #Doesn't take away nor give you story items")
	EID:addTrinket(CustomTrinkets.PIECE_OF_CHALK, "When entering uncleared room, you will leave a trail of powder #Enemies walking on the powder will be significantly slowed down #The powder lasts for 10 seconds")
	EID:addTrinket(CustomTrinkets.ADAMS_RIB, "Revives you as Eve when you die")
	EID:addTrinket(CustomTrinkets.NIGHT_SOIL, "75% chance to prevent a curse when entering a new floor")
	EID:addTrinket(CustomTrinkets.BONE_MEAL, "At the beginning of every new floor, grants:#{{ArrowUp}} +10% DMG up #{{ArrowUp}} Size increase #Both damage and size up stay if you drop the trinket")
	EID:addTrinket(CustomTrinkets.TORN_PAGE, "Amplifies or changes book's activation effects, or makes them charge faster #Apart from natural spawns, this trinket has a 33% chance to spawn in libraries")
	EID:addTrinket(CustomTrinkets.EMPTY_PAGE, "Books now activate a random active item on use #Doesn't work on How to Jump and doesn't proc dice and items that hurt or kill you #Apart from natural spawns, this trinket has a 33% chance to spawn in libraries")
	EID:addTrinket(CustomTrinkets.BABY_SHOES, "Reduces the size of all enemies by 20% #This affects both sprite and hitbox #Affects bosses too")
	EID:addTrinket(CustomTrinkets.KEY_KNIFE, "5% chance to activate Dark Arts effect when taking damage #Increases the spawn rates of Black chests in Devil rooms")
	
	EID:addCard(CustomConsumables.SPINDOWN_DICE_SHARD, "Invokes the effect of Spindown Dice")
	EID:addCard(CustomConsumables.RED_RUNE, "Damages all enemies in a room, turns item pedestals into red locusts and turns CustomPickups into random locusts with a 50% chance")
	EID:addCard(CustomConsumables.NEEDLE_AND_THREAD, "Removes one broken heart and grants one {{Heart}} heart container")
	EID:addCard(CustomConsumables.QUEEN_OF_DIAMONDS, "Spawns 1-12 random {{Coin}} coins (those can be nickels or dimes as well)")
	EID:addCard(CustomConsumables.KING_OF_SPADES, "Lose all your keys and spawn a number of CustomPickups proportional to the amount of keys lost #At least 9 {{Key}} keys is needed for a trinket, and at least 21 for an item #If Isaac has {{GoldenKey}} Golden key, it is removed too and increases total value")
	EID:addCard(CustomConsumables.KING_OF_CLUBS, "Lose all your bombs and spawn a number of CustomPickups proportional to the amount of bombs lost #At least 9 {{Bomb}} bombs is needed for a trinket, and at least 21 for an item #If Isaac has {{GoldenBomb}} Golden bomb, it is removed too and increases total value")
	EID:addCard(CustomConsumables.KING_OF_DIAMONDS, "Lose all your coins and spawn a number of CustomPickups proportional to the amount of coins lost #At least 24 {{Coin}} coins is needed for a trinket, and at least 54 for an item")
	EID:addCard(CustomConsumables.BAG_TISSUE, "All CustomPickups in a room are destroyed, and 8 most valuables CustomPickups form an item quality based on their total weight; the item of such quality is then spawned #The most valuable CustomPickups are the rarest ones, e.g. {{EthernalHeart}} Eternal hearts or {{Battery}} Mega batteries #{{Warning}} If used in a room with less then 8 CustomPickups, no item will spawn!")
	EID:addCard(CustomConsumables.JOKER_Q, "Teleports Isaac to a {{SuperSecretRoom}} Black Market")
	EID:addCard(CustomConsumables.UNO_REVERSE_CARD, "Invokes the effect of Glowing Hourglass")
	EID:addCard(CustomConsumables.LOADED_DICE, "{{ArrowUp}} Grants +10 Luck for the current room")
	EID:addCard(CustomConsumables.BEDSIDE_QUEEN, "Spawns 1-12 random {{Key}} keys #There is a small chance to spawn a charged key")
	EID:addCard(CustomConsumables.QUEEN_OF_CLUBS, "Spawns 1-12 random {{Bomb}} bombs #There is a small chance to spawn a double-pack bomb")
	EID:addCard(CustomConsumables.JACK_OF_CLUBS, "Bombs will drop more often after clearing rooms for the current floor, and the average quality of bombs is increased")
	EID:addCard(CustomConsumables.JACK_OF_DIAMONDS, "Coins will drop more often after clearing rooms the for current floor, and the average quality of coins is increased")
	EID:addCard(CustomConsumables.JACK_OF_SPADES, "Keys will drop more often after clearing rooms for the current floor, and the average quality of keys is increased")
	EID:addCard(CustomConsumables.JACK_OF_HEARTS, "Hearts will drop more often after clearing rooms for the current floor, and the average quality of hearts is increased")
	EID:addCard(CustomConsumables.QUASAR_SHARD, "Damages all enemies in a room and turns every item pedestal into 3 Lemegeton wisps")
	EID:addCard(CustomConsumables.BUSINESS_CARD, "Summons a friendly monster, like ones from Friend Finder")
	EID:addCard(CustomConsumables.SACRIFICIAL_BLOOD, "{{ArrowUp}} Gives +1.25 DMG up that depletes over the span of 20 seconds #Stackable #{{ArrowUp}} Heals you for one red heart if you have Ceremonial Robes #{{Warning}} Damage depletes quicker the more Blood you used subsequently")
	EID:addCard(CustomConsumables.LIBRARY_CARD, "Activates a random book effect")
	EID:addCard(CustomConsumables.FLY_PAPER, "Grants 8 fly orbitals, similar to the Swarm item")
	EID:addCard(CustomConsumables.MOMS_ID , "Charms all enemies in the current room")
	EID:addCard(CustomConsumables.FUNERAL_SERVICES , "Spawns an Old Chest")
	EID:addCard(CustomConsumables.ANTIMATERIAL_CARD , "Can be thrown similarly to Chaos Card #If the card touches an enemy, that enemy is erased for the rest of the run")
	EID:addCard(CustomConsumables.FIEND_FIRE, "Sacrifice your consumables for mass room destruction #7-40 total: enemies take 15 damage and burn for 4 seconds #41-80 total: the initital damage, the burning damage and burning duration are doubled; destroys obstacles around you #81+ total: the burning damage and burning duration are quadrupled; produces a Mama Mega explosion")
	EID:addCard(CustomConsumables.DEMON_FORM, "{{ArrowUp}} Increases your damage by 0.15 for every new uncleared room you enter #The boost disappears when entering a new floor")
	EID:addCard(CustomConsumables.MIRRORED_LANDSCAPE , "If you don't have a pocket item your active item becomes pocket item #If you already have a pocket item spawns a copy of it")
	
	EID:addPill(CustomPills.ESTROGEN, "Turns all your red health into blood clots #Leaves you at one red heart other types of hearts are unaffected")
	EID:addPill(CustomPills.LAXATIVE, "Makes you shoot out corn tears from behind for 3 seconds")
	EID:addPill(CustomPills.PHANTOM_PAINS, "Makes Isaac take fake damage on pill use, then 15 and 30 seconds after")
	EID:addPill(CustomPills.YUCK, "Spawns a rotten heart #For 30 seconds, every red heart will spawn blue flies when picked up")
	EID:addPill(CustomPills.YUM, "Spawns a red heart #For 30 seconds, every red heart will grant you small permanent stat upgrades when picked up")
	
	--EID Spanish
	EID:addCollectible(CustomCollectibles.ORDINARY_LIFE, "{{ArrowUp}} Tears up", "Vida Ordinaria", "spa")	
	EID:addCollectible(CustomCollectibles.COOKIE_CUTTER, "Te otorga un {{Heart}} un contenedor de corazón y un corazón roto#{{Warning}} ¡Tener 12 corazones te matará!", "Cortador de Galletas", "spa")
	EID:addCollectible(CustomCollectibles.SINNERS_HEART, "{{ArrowUp}} +2 de daño, multiplicador de daño x1.5#{{ArrowDown}} baja la velocidad de tiro#lágrimas teledirigidas", "Corazón de los Pecadores", "spa")
	EID:addCollectible(CustomCollectibles.RUBIKS_CUBR, "Tras cada uso, hay un 5% (100% en el uso 20) de probabilidad de 'resolverlo', cuando esto ocurre, se le remueve al jugador y es reemplazado con un Cubo Mágico", "Cubo de Rubik", "spa")
	EID:addCollectible(CustomCollectibles.MAGIC_CUBE, "{{DiceRoom}} Rerolea los pedestales de objetos #Los items reroleados se toman de cualquier pool", "Cubo Mágico", "spa")
	EID:addCollectible(CustomCollectibles.MAGIC_PEN, "Las lágrimas dejan {{ColorRainbow}}{{CR}} creep arcoíris bajo ellas #Efectos de estado permantenes se aplican a los enemigos que caminen por el creep", "Pluma Mágica", "spa")
	EID:addCollectible(CustomCollectibles.MARK_OF_CAIN, "Si mueres y tienes algún familiar, son eliminados a cambio de revivir #Al revivir, mantienes tus corazones, ganas +0.4 de daño por cada familiar sacrificado y ganas invencibilidad#{{Warning}}¡Sólo funciona una vez!", "La Marca de Cain", "spa")
	EID:addCollectible(CustomCollectibles.TEMPER_TANTRUM, "Al recibir daño, Hay un 25% de probabiliad de entrar al modo Berserk #Mientras el modo esté activo, Cada enemigo dañado tiene un 10% de ser eliminado de la partida", "Temper Tantrum", "spa")
	EID:addCollectible(CustomCollectibles.BAG_O_TRASH, "Un familiar que genera moscas azules al limpiar una habitación #Puede bloquear disparos, al recibir un golpe tiene la posibilidad de romperse y otorgar {{Collectible25}}Desayuno o el trinket La Tierra de la Noch #Mientras más pisos pases sin romperlo, más moscas generará", "Bolsa de Basura", "spa")
	EID:addCollectible(CustomCollectibles.CHERUBIM, "Un familiar que lanza lágrimas de {{Collectible331}} Cabeza de Dios a una cadencia de tiro alta", "Bebé Zen", "spa")
	EID:addCollectible(CustomCollectibles.CHERRY_FRIENDS, "Matar a un enemigo otorga un 20% de posibilidad de soltar un familiar cereza en el suelo #Estas cerezas emiten un pedo con efecto encantador cuando un enemigo camina sobre ellos, sueltan medio corazón al limpiar la habitación", "Amigos de Cereza", "spa")
	EID:addCollectible(CustomCollectibles.BLACK_DOLL, "Al entrar en una nueva habitación, Los enemigos serán divididos en pares. Dañar a un enemigo de un par, provocará la mitad del daño hecho en la otra mitad del par", "Muñeco Negro", "spa")
	EID:addCollectible(CustomCollectibles.BIRD_OF_HOPE, "Al morir, revivirás como un fantasma invencible y un pájaro azul saldrá del centro de la habitación a una dirección aleatoria. Atrapar al pájaro en menos de 5 segundos te salvará y regreserás al punto donde moriste, de otra forma, morirás #{{Warning}} Cada vez que mueres, el pájaro volará con mayor velocidad, volviéndolo más difícil de atrapar", "Un Pájaro de la Esperanza", "spa")
	EID:addCollectible(CustomCollectibles.ENRAGED_SOUL, "Presionar dos veces el botón de disparo hará que lances un fantasma en esa dirección#El fantasma se pegará con el primer enemigo con el que choque, dañándolo por 7 segundos o hasta que el enemigo muera #El fantasma también afecta a los jefes #{{Warning}}Tiene un cooldown de 7 segundos", "Alma Iracunda", "spa")
	EID:addCollectible(CustomCollectibles.CEREMONIAL_BLADE, "{{ArrowDown}}Multiplicador de daño de x0.85 #Al disparar, hay un 5% de probabilidad de lanzar una daga que no hiere a los enemigos, pero los hace sangrar#Todo enemigo que muera desangrado soltará el consumible Sangre de Sacrificio, el cual otorgará un {{ArrowUp}}aumento de daño", "Daga Ceremonial", "spa")
	EID:addCollectible(CustomCollectibles.CEILING_WITH_THE_STARS, "Otorga dos flamas de {{Collectible712}} Lemegeton por cada piso avanzado y cama a la que se va a dormir", "Móvil de estrellas", "spa")
	EID:addCollectible(CustomCollectibles.QUASAR, "Consume todos los objetos en pedestal y otorga 3 flamas de {{Collectible712}}Lemegeton", "Quasar", "spa")
	EID:addCollectible(CustomCollectibles.TWO_PLUS_ONE, "Cada tercer objeto comprado en la tienda del piso actual costará 1 {{Coin}} penny #Comprar 2 objetos con corazones en una habitación hará que los demás se vuelvan gratuitos", "2+1", "spa")
	EID:addCollectible(CustomCollectibles.RED_MAP, "Revela la ubicación de la Sala Ultra Secreta en los siguientes pisos#Cualquier trinket que se deje en una {{TreasureRoom}}sala del tesoro o {{BossRoom}}sala del jefe dejará una Cracked Key", "Mapa Rojo", "spa")
	EID:addCollectible(CustomCollectibles.CHEESE_GRATER, "Remueve un contenedor de corazón rojo y otorga {{ArrowUp}} +0.5 de daño y 2 mini Isaacs", "Rayador de Queso", "spa")
	EID:addCollectible(CustomCollectibles.DNA_REDACTOR, "Ahora las píldoras reciben efectos adicionales en base a su color", "Redactor de ADN", "spa")
	EID:addCollectible(CustomCollectibles.TOWER_OF_BABEL, "Destruye los obstáculos de la habitación y aplica confusión a los enemigos cercanos #Destroza las puertas y abre la entrada a Salas Secretas", "La Torre de Babel", "spa")
	EID:addCollectible(CustomCollectibles.BLESS_OF_THE_DEAD, "Previene las maldiciones durante toda la partida #Si se previene una maldición recibes {{ArrowUp}} +0.5 de daño", "Bendición de los muertos", "spa")
	EID:addCollectible(CustomCollectibles.TANK_BOYS, "Genera 2 tanques de juguete que rondan por la habitación y atacan a los enemigos dentro de su linea de visión #Tanque verde: Dispara balas rápidamente a los enemigos a gran distancia y es de movimiento rápido #Tanque rojo: Dispara cohetes a corto rango, de movimiento lento", "Tanquesitos", "spa")
	EID:addCollectible(CustomCollectibles.GUSTY_BLOOD, "Matar a los enemigos te da {{ArrowUp}} más lágrimas y velocidad #Se resetea al entrar a una nueva habitación", "Sangre Tempestuosa", "spa")
	EID:addCollectible(CustomCollectibles.RED_BOMBER, "+5 bombas #Ganas inmunidad a explosiones #Ahora puedes arrojar las bombas en vez de simplemente ponerlas en el suelo", "Bombardero Rojo", "spa")
	EID:addCollectible(CustomCollectibles.MOTHERS_LOVE, "Otorga aumentos de estadísticas en base a tus familiares#Algunos darán buenos aumentos, y otros no los darán del todo (p.e. Moscas azules, dips o partes del cuerpo de Isaac)", "Amor Maternal", "spa")
	EID:addCollectible(CustomCollectibles.CAT_IN_A_BOX, "Al entrar a una habitación con jefes, su salud se reduce a la mitad por 3 segundos, luego se restaura#No funciona en jefes o mini jefes", "Un gato en la caja", "spa")
	EID:addCollectible(CustomCollectibles.BOOK_OF_GENESIS, "Retira un objeto aleatorio y genera 3 objetos de la misma calidad#Sólo puedes tomar uno#No remueve o genera objetos relacionados a la historia", "Libro del Génesis", "spa")
	EID:addCollectible(CustomCollectibles.SCALPEL, "Ahora disparas en la dirección opuesta#De lado frontal, dispararás rápidamente unas lágrimas sangrientas que hacen tu daño x0.66#Otro tipo de ataques serán disparados regularmente", "Un bisturí", "spa")
	EID:addCollectible(CustomCollectibles.KEEPERS_PENNY, "Genera una moneda dorada al entrar a un nuevo piso#Las tiendas ahora venden 1-4 objetos adicionales tomados de la tienda, sala del tesoro o sala del jefe", "El centavo de Keeper", "spa")
	EID:addCollectible(CustomCollectibles.NERVE_PINCH, "Disparar o moverse en una dirección durante 5 segundos generará un pincho nervioso#{{ArrowDown}} Tomas daño falso y recibes " .. tostring(CustomStatups.NERVEPINCH_SPEED) .. " de velocidad permanente cuando ocurre#{{ArrowUp}} Sin embatgo, hay un 75% de posibilidad de usar tu activo gratis, Incluso si no está cargado#Objetos de un solo uso y de cargas infinitas no pueden usarse de esta forma", "Pincho nervioso", "spa")
	EID:addCollectible(CustomCollectibles.BLOOD_VESSELS[1], "Tomar daño no herirá al jugador, en vez de eso se llenará un contenedor de sangre#Puede ser repeetido hasta 6 veces, cuando este se llenará#Cuando esté lleno, usarlo o recibir daño lo vaciará y se provocará 3 corazones de daño al jugador", "Contenedor de sangre", "spa")
	EID:addCollectible(CustomCollectibles.SIBLING_RIVALRY, "Un orbital que cambia en 2 distintos estados cada 15 segundos:#Dos orbitales que giran rápidamente alrededor de Isaac #Un orbital que gira más lento y cerca de Isaac, dispara dientes y suelta creep rojo bajo el #{{Warning}} Ambas fases bloquean proyectiles y hacen daño por contacto", "Rivalidad entre hermanos", "spa")
	
	EID:addTrinket(CustomTrinkets.BASEMENT_KEY, "{{ChestRoom}} Al tenerlo, cada Cofre Dorado tiene un 12.5% de probabilidad de convertirse en un Cofre Viejo", "Llave del Sótano", "spa")
	EID:addTrinket(CustomTrinkets.KEY_TO_THE_HEART, "Al tenerlo, cada enemigo tiene una posibilidad de soltar un Cofre Escarlata al morir#Los Cofres Escarlata contienen: 1-4 {{Heart}} corazones/{{Pill}} píldoras O un objeto aleatorio relativo al cuerpo", "Llave al Corazón", "spa")
	EID:addTrinket(CustomTrinkets.JUDAS_KISS, "Los enemigos que te toquen serán marcados y atacados por otros enemigos (Efecto similar al de {{Collectible618}} Tomate Podrido", "Beso de Judas", "spa")
	EID:addTrinket(CustomTrinkets.TRICK_PENNY, "Usar una moneda, llave o bomba en una máquina, un mendigo o un cofre cerrado tendrá un 17% de probabilidad de no restarlo de tu ivnentario", "Moneda Truculenta", "spa")
	EID:addTrinket(CustomTrinkets.SLEIGHT_OF_HAND, "Al momento de generarse, cada moneda tiene un 20% de posibilidad de recibir una mejora: #penny -> penny doble -> nickel pegajoso -> nickel -> décimo -> penny de la suerte -> penny dorado", "Juego de Manos", "spa")
	EID:addTrinket(CustomTrinkets.GREEDS_HEART, "Te otorga una Moneda corazón vacía #Esta se vacía antes que tus corazones regulares, se rellena consiguiendo dinero", "Corazón de la Codicia", "spa")
	EID:addTrinket(CustomTrinkets.ANGELS_CROWN, "Toda nueva sala del ángel tendrá un objeto de la pool del ángel a la venta en vez de un objeto de la pool del tesoro#Los ángeles de las estatuas no generarán {{Collectible238}}{{Collectible239}}Piezas de Llave", "Corona de Ángel", "spa")
	EID:addTrinket(CustomTrinkets.MAGIC_SWORD, "{{ArrowUp}} x2 de daño al sostenerlo#Se rompe al recibir daño#{{ArrowUp}}Tener Cinta Adhesiva evitará que se rompa", "Espada Mágica", "spa")
	EID:addTrinket(CustomTrinkets.WAIT_NO, "No hace nada, está rota", "Espera... ¡NO!", "spa")
	EID:addTrinket(CustomTrinkets.EDENS_LOCK, "Al recibir daño, uno de tus objetos será reroleado a otro objeto aleatorio #No quita ni otorga objetos relativos a la historia", "Mechón de Eden", "spa")
	EID:addTrinket(CustomTrinkets.PIECE_OF_CHALK, "Al entrar a una sala nueva, dejarás un rastro de talco bajo tuyo durante 5 segundos#Los enemigos que intenten caminar por el rastro serán repelidos", "Pedazo de Tiza", "spa")
	EID:addTrinket(CustomTrinkets.ADAMS_RIB, "Revives como Eve al morir", "Costilla de Adan", "spa")
	EID:addTrinket(CustomTrinkets.NIGHT_SOIL, "40% de posibilidad de prevenir una maldición al pasar a un nuevo piso", "La Tierra de la Noche", "spa")
	EID:addTrinket(CustomTrinkets.BONE_MEAL, "{{ArrowUp}} Aumenta el daño y el tamaño por piso al tener la baratija", "Harina de huesos", "spa")
	EID:addTrinket(CustomTrinkets.TORN_PAGE, "Los libros tienen efectos adicionales al usarlos", "Pagina destrozada", "spa")
	EID:addTrinket(CustomTrinkets.EMPTY_PAGE, "Los libros activan un efecto aleatorio al usarlo #No funciona con How to Jump# no activa efectos de dado u objetos que te dañen #{{ArrowUp}} 33% de posibilidad de aparecer en bibliotecas", "Página vacía", "spa")
	EID:addTrinket(CustomTrinkets.BABY_SHOES, "{{ArrowDown}} -20% al tamaño de los enemigos#Afecta también a los jefes#{{Warning}} Se reduce tanto el tamaño como la hitbox", "Zapatitos de bebé", "spa")
	
	EID:addCard(CustomConsumables.SPINDOWN_DICE_SHARD, "Efecto de {{Collectible723}} Spindown Dice de un solo uso", "Fragmento de Spindown Dice", "spa")
	EID:addCard(CustomConsumables.RED_RUNE, "Daña a todos los enemigos de una habitación, los objetos en pedestales se convierten en langostas rojas y los consumibles tienen 50% de probabilidad de convertirse en una langosta roja", "Runa Roja", "spa")
	EID:addCard(CustomConsumables.NEEDLE_AND_THREAD, "Remueve un Corazón Roto y otorga un {{Heart}} Contenedor de Corazón", "Aguja e Hilo", "spa")
	EID:addCard(CustomConsumables.QUEEN_OF_DIAMONDS, "Genera 1-12 {{Coin}} monedas aleatorias (pueden ser tanto nickels como décimos)", "Reina de Diamantes", "spa")
	EID:addCard(CustomConsumables.KING_OF_SPADES, "Pierdes todas tus llaves y se genera un número proporcional a la cantidad perdida en recolectables #Se necesitan al menos 12 {{Key}} llaves para generar un trinket y al menos 28 para un objeto#Si Isaac tiene una {{GoldenKey}} Llave Dorada, Será removida y aumentará el valor de la recompensa significativamente", "Rey de Espadas", "spa")
	EID:addCard(CustomConsumables.KING_OF_CLUBS, "Pierdes todas tus bombas y se genera un número proporcional a la cantidad perdida en recolectables#Se necesitan al menos 12 {{Bomb}} bombas para generar un trinket y al menos 28 para un objeto#Si Isaac tiene una {{GoldenBomb}} Bomba Dorada, Será removida y aumentará el valor de la recompensa significativamente", "Rey de Tréboles", "spa")
	EID:addCard(CustomConsumables.KING_OF_DIAMONDS, "Pierdes todas tus monedas y se genera un número proporcional a la cantidad perdida en recolectables#Se necesitan al menos 12 {{Coin}} monedas para generar un trinket y al menos 28 para un objeto", "Rey de Diamantes", "spa")
	EID:addCard(CustomConsumables.BAG_TISSUE, "Destruye todos los recolectables, y los ocho recolectables de mayor valor generarán un objeto con una calidad basada en el valor de los recolectables#Los recolectables con mayor valor son los más raros, por ejemplo:{{EthernalHeart}} Corazones Eternos o {{Battery}} Mega Baterías#{{Warning}} Si se usa en una habitación sin recolectables, no generará nada", "Bolsa de tela", "spa")
	EID:addCard(CustomConsumables.JOKER_Q, "Teletransporta a Isaac a un {{SuperSecretRoom}} Mercado Negro")
	EID:addCard(CustomConsumables.UNO_REVERSE_CARD, "Activa el efecto de {{Collectible422}} Reloj de arena brillante", "¿Comodín?", "spa")
	EID:addCard(CustomConsumables.LOADED_DICE, "{{ArrowUp}} +10 de suerte durante una habitación")
	EID:addCard(CustomConsumables.BEDSIDE_QUEEN, "Genera 1-12 {{Key}} llaves#Hay una posibilidad de generar una Llave Cargada", "Reina de Espadas", "spa")
	EID:addCard(CustomConsumables.QUEEN_OF_CLUBS, "Genera 1-12 {{Bomb}} bombas#Hay una posibilidad de generar una bomba doble", "Reina de Tréboles", "spa")
	EID:addCard(CustomConsumables.JACK_OF_CLUBS, "Se generarán más bombas al limpiar habitaciones, la calidad general de las bombas aumenta", "Jota de Tréboles", "spa")
	EID:addCard(CustomConsumables.JACK_OF_DIAMONDS, "Se generarán más monedas al limpiar habitaciones, la calidad general de las monedas aumenta", "Jota de Diamantes", "spa")
	EID:addCard(CustomConsumables.JACK_OF_SPADES, "Se generarán más llaves al limpiar habitaciones, la calidad general de las llaves aumenta", "Jota de Espadas", "spa")
	EID:addCard(CustomConsumables.JACK_OF_HEARTS, "Se generarán más corazones al limpiar habitaciones, la calidad general de los corazones aumenta", "Jota de Corazones", "spa")
	EID:addCard(CustomConsumables.QUASAR_SHARD, "Dañaa todos los enemigos de la habitación, convierte cada pedestal de objeto en 3 flamas de {{Collectible712}} Lemegeton", "Fragmento de Quasar", "spa")
	EID:addCard(CustomConsumables.BUSINESS_CARD, "Invoca un enemigo aliado aleatorio, al igual que {{Collectible687}} Buscador de Amigos", "Carta de Negocios", "spa")
	EID:addCard(CustomConsumables.SACRIFICIAL_BLOOD, "{{ArrowUp}} +1 de daño que decrementa tras 25 segundos#Acumulable#{{ArrowUp}} Cura un corazón rojo si tienes {{Collectible216}} Batas Ceremoniales#{{Warning}} El daño disminuirá más rápido mientras más sangre uses", "Sangre de Sacrificio", "spa")
	EID:addCard(CustomConsumables.LIBRARY_CARD, "Activa un efecto aleatorio de un Libro", "Carta de Biblioteca", "spa")
	EID:addCard(CustomConsumables.FLY_PAPER, "Genera 8 moscas de {{Collectible693}} El Enjambre", "Trampa para Moscas", "spa")
	EID:addCard(CustomConsumables.MOMS_ID, "Encanta a todos los enemigos de la habitación", "Identificación de Mamá", "spa")
	EID:addCard(CustomConsumables.FUNERAL_SERVICES, "Genera un Cofre Viejo", "Servicios de Funeraria", "spa")
	EID:addCard(CustomConsumables.ANTIMATERIAL_CARD, "Se lanza igual que una Carta del caos#Si la carta toca a un enemigo, este es eliminado por el resto de la partida", "Carta Antimaterial", "spa")
	EID:addCard(CustomConsumables.FIEND_FIRE, "Elimina tus recolectables para provocar daño en masa #10-50 en total: Los enemigos toman 15 de daño y se queman por 4 segundos#51-125 total: El daño inicial, el daño de quemadura y duración de la misma se duplican; Destruye obstáculos cerca tuyo#126-150 total: El daño y duración de quemaduras se cuadriplica; produce una explosión de Mamá Mega", "Fuego del demonio", "spa")
	EID:addCard(CustomConsumables.DEMON_FORM, "{{ArrowUp}} +0.15 de daño por cada sala nueva a la que entres#El efecto desaparece al entrar a un nuevo piso", "Forma demoniaca", "spa")
	
	EID:addPill(CustomPills.ESTROGEN, "Convierte todos tus {{Heart}}corazones en Coágulos#Te deja con al menos un corazón rojo, No afecta Corazones de Alma/Corazones Negros", "Estrógeno", "spa")
	EID:addPill(CustomPills.LAXATIVE, "Hace que dispares los maíces de {{Collectible680}}Venganza de Montezuma durante 3 segundos", "Laxante", "spa")
	EID:addPill(CustomPills.PHANTOM_PAINS, "Provoca que Isaac reciba daño falso al usarse, luego a los 20 y 40 segundos de haberla consumido", "Fantasma", "spa")
	EID:addPill(CustomPills.YUCK, "Genera un corazón podrido #Por 30 segundos, cada corazón rojo tomado generará moscas azules", "Puaj", "spa")
	EID:addPill(CustomPills.YUM, "Genera un corazón rojo #Por, cada corazón rojo que consigas te dará un pequeño aumento permantente de estadísticas, Igual al efecto de {{Collectible671}} Corazón de Caramelo", "Mmm~", "spa")

	-- EID Russian
	EID:addCollectible(CustomCollectibles.ORDINARY_LIFE, "{{ArrowUp}} Повышает скорострельность #Создает дополнительный предмет, связанный с матерью/отцом, в сокровищницах; можно взять только один предмет", "Обычная Жизнь", "ru")	
	EID:addCollectible(CustomCollectibles.COOKIE_CUTTER, "При использовании дает один {{Heart}} контейнер сердца и одно сломанное сердце #{{Warning}} При 12 сломанных сердец вы умрете!", "Формочка для Печенья", "ru")
	EID:addCollectible(CustomCollectibles.SINNERS_HEART, "+2 черных сердца #{{ArrowUp}} Дает +2 к урону и умножает на 1.5 #{{ArrowUp}} Дает +2 к дальности и -0.2 к скорости слезы #Дает спектральные и пронзающие слезы", "Сердце Грешника", "ru")
	EID:addCollectible(CustomCollectibles.RUBIKS_CUBR, "После каждого использования, имеет 5%(100% на 20-ом использовании) шанс стать 'собранным', забирает у игрока этот предмет и заменяет его Магическим Кубом", "Кубик Рубика", "ru")
	EID:addCollectible(CustomCollectibles.MAGIC_CUBE, "{{DiceRoom}} Меняет предметы в комнате #Замененные предметы могут быть из любого пула предметов", "Магический Куб", "ru")
	EID:addCollectible(CustomCollectibles.MAGIC_PEN, "При двойном нажатие кнопки стрельбы создает на полу полосу {{ColorRainbow}}радужной{{CR}} лужи в направлении стрельбы #Лужа накладывает случайные статусные эффекты врагам при соприкосновении#{{Warning}} Имеет 4 секунды перезарядки", "Магическая Ручка", "ru")
	EID:addCollectible(CustomCollectibles.MARK_OF_CAIN, "Дарует вам спутника Еноха #Когда вы умираете, если у вас есть какие-либо спутники, кроме Еноха, воскрешает вас и уничтожает их вместо этого; Енох становится сильнее; дает вам кадры неуязвимости и сохраняет все ваши красные контейнеры #{{Warning}} Работает только один раз", "Метка Каина", "ru")
	EID:addCollectible(CustomCollectibles.TEMPER_TANTRUM, "При получении урона, есть 25% шанс войти в режим Берсерка #В этом состоянии, любой пораженный враг имеет 10% шанс стать стертым до конца забега", "Приступ Ярости", "ru")
	EID:addCollectible(CustomCollectibles.BAG_O_TRASH, "Спутник призывающий мух при зачистке комнат #Блокирует вражеские выстрелы, при блокировании имеет небольшой шанс быть уничтоженным и создать предмет Завтрак или брелок Ночное Золото #Чем больше этажей этот спутник выживает, тем больше мух он призывает", "Мешок для Мусора", "ru")
	EID:addCollectible(CustomCollectibles.CHERUBIM, "Спутник, быстро стреляющий слезами с аурой {{Collectible331}} Головы Бога", "Херувим", "ru")
	EID:addCollectible(CustomCollectibles.CHERRY_FRIENDS, "При убийстве врага есть 20% шанс призвать на его месте спутника вишенку #Вишенки испускают очаровывающий пук при соприкосновении с врагами, и создает половинку красного сердца после зачистки комнаты", "Вишенки", "ru")
	EID:addCollectible(CustomCollectibles.BLACK_DOLL, "При посещении комнаты, все враги будут разделены на пары. Нанося урон врагу, также наносит половину урона другому врагу в этой паре", "Черная Кукла", "ru")
	EID:addCollectible(CustomCollectibles.BIRD_OF_HOPE, "При смерти персонаж превращается в неуязвимого призрака, и птица вылетает из центра комнаты в случайном направление. При поимке птицы вы воскрешаетесь и возвращаетесь на место своей смерти, если вы не успеваете поймать птицу вы умираете. Ужасной смертью #{{Warning}} За каждую вашу смерть, птица становится быстрее, затрудняя ее поймать", "Птичка Надежды", "ru")
	EID:addCollectible(CustomCollectibles.ENRAGED_SOUL, "При двойном нажатии кнопки стрельбы запускает призрака в направление стрельбы #Призрак прилипнет ко врагу нанося урон на протяжении 7 секунд или до тех пор пока этот враг умрет#Призрак наносит 7 урона и повышается каждый этаж #Также Призрак может прилипать к боссам #{{Warning}} Призрак имеет 7 секунд перезарядки", "Разъяренная Душа", "ru")
	EID:addCollectible(CustomCollectibles.CEREMONIAL_BLADE, "При стрельбе есть 7%  шанс запустить кинжал, который не наносит урона, но накладывает кровотечение на врагов #Враги которые умерли пока кровоточили оставят за собой Жертвенную Кровь, которая дает временную прибавку к урону", "Церемониальный Кинжал", "ru")
	EID:addCollectible(CustomCollectibles.CEILING_WITH_THE_STARS, "Дает 2 огонька {{Collectible712}} Лемегетона в начале каждого этажа и когда вы спите в кровати ", "Потолок со Звездами", "ru")
	EID:addCollectible(CustomCollectibles.QUASAR, "Поглощает все предметы на пьедесталах в комнате и дает 3 огонька {{Collectible712}} Лемегетона за каждый поглощенный предмет", "Квазар", "ru")
	EID:addCollectible(CustomCollectibles.TWO_PLUS_ONE, "Каждый третий купленный предмет будет стоить 1 {{Coin}} пенни #Покупка двух предметов сердцами сделает все остальные предметы бесплатными", "2+1", "ru")
	EID:addCollectible(CustomCollectibles.RED_MAP, "Показывает местоположение Ультра Секретной Комнаты на последующих этажах #Любой брелок оставленный в комнате босса или сокровищнице превратиться в Треснутый Ключ", "Красная Карта", "ru")
	EID:addCollectible(CustomCollectibles.CHEESE_GRATER, "Забирает один контейнер сердца и дает {{ArrowUp}} +0.5 к урону и создает 3 мини Айзека", "Терка для Сыра", "ru")
	EID:addCollectible(CustomCollectibles.DNA_REDACTOR, "Пилюли дают дополнительный эффект в зависимости от их цвета", "Редактор ДНК", "ru")
	EID:addCollectible(CustomCollectibles.TOWER_OF_BABEL, "Уничтожает все препятствия в этой комнате и накладывает на врагов в маленьком радиусе замешательство #Также подрывает двери и проход в секретную комнату", "Вавилонская Башня", "ru")
	EID:addCollectible(CustomCollectibles.BLESS_OF_THE_DEAD, "Предотвращает проклятья до конца забега #Предотвращение проклятья дает вам {{ArrowUp}} +" .. tostring(CustomStatups.BLESS_DMG) .. " к урону", "Благословение Мертвых", "ru")
	EID:addCollectible(CustomCollectibles.TANK_BOYS, "Призывает двух спутников Танкистов, которые катаются по комнате и атакуют врагов находящиеся в их поле зрения #Зеленый танк: быстро стреляет по врагам на далекой дистанции и двигается быстро #Красный танк: стреляет ракетами по врагам на маленькой дистанции и двигается медленно", "Танкисты", "ru")
	EID:addCollectible(CustomCollectibles.GUSTY_BLOOD, "Убийство врагов дает {{ArrowUp}} повышение к скорострельности и к скорости #Бонус пропадает при выходе из комнаты", "Бурная Кровь", "ru")
	EID:addCollectible(CustomCollectibles.RED_BOMBER, "+5 бомб #Дает иммунитет к взрывам #Позволяет вам бросать бомбы", "Красный Бомбардировщик", "ru")
	EID:addCollectible(CustomCollectibles.MOTHERS_LOVE, "Дает повышение к случайной характеристике за каждого спутника", "Мамина Любовь", "ru")
	EID:addCollectible(CustomCollectibles.CAT_IN_A_BOX, "При входе в комнату с врагами их здоровье уменьшается вдвое в течение первых 3 секунд, а затем восстанавливается до полного #Не работает с боссами или минибоссами", "Кот в Коробке", "ru")
	EID:addCollectible(CustomCollectibles.BOOK_OF_GENESIS, "Удаляет ваш случайный предмет и создает три предмета того же качества #Только один предмет можно взять", "Книга Бытия", "ru")
	EID:addCollectible(CustomCollectibles.SCALPEL, "Вы будете стрелять слезами в противоположном направлении #Спереди вы быстро будете стрелять кровавыми слезами, которые наносят х0,66 вашего урона #Все остальные типы оружия также будут выпущены спереди", "Скальпель", "ru")
	EID:addCollectible(CustomCollectibles.KEEPERS_PENNY, "Создает золотую монетку при переходе на новый этаж #Магазины теперь будут продавать 1-4 дополнительных предмета, взятых из пула магазина, сокровищницы или комнаты босса #Если в магазине будет битва с Алчностью, создает 3-4 предмета, когда мини-босс умирает", "Монетка Хранителя", "ru")
	EID:addCollectible(CustomCollectibles.NERVE_PINCH, "При стрельбе или ходьбе в течение 8 секунд  #{{ArrowDown}} Вы получаете фальшивый урон и " .. tostring(CustomStatups.NERVEPINCH_SPEED) .. " к скорости #{{ArrowUp}} C 75% шансом активирует ваш активный предмет, даже если он не заряжен #Одноразовое", "Защемление Нерва", "ru")
	EID:addCollectible(CustomCollectibles.BLOOD_VESSELS[1], "Получение урона не причиняет вреда игроку, вместо этого заполняет сосуд #Это можно повторить 6 раз, пока сосуд не заполнится #Как только он заполнится, его использование или получение урона опустошит его и нанесет игроку 3 и 3,5 сердца урона соответственно.", "Кровавый Сосуд", "ru")
	EID:addCollectible(CustomCollectibles.SIBLING_RIVALRY, "Орбитал который переключается между двумя состояниями: #Два орбитала которые кружатся около игрока #Орбитал который кружится медленее, и случайно стреляет зубами в случайных направлениях и создает кровавые лужи под ними #{{Warning}} Все орбиталы блокируют снаряды и наносят контактный урон", "Соперничество", "ru")
	EID:addCollectible(CustomCollectibles.RED_KING, "После победы над боссом в середине комнаты появится красный люк #Люк приведет вас к другому бою с боссом высокой сложности #Победа вознаграждает вас красным предметом", "Красный Король", "ru")
	EID:addCollectible(CustomCollectibles.STARGAZERS_HAT, "Создает попрошайку Астронома #Предмет заряжается только синими сердцами #2 сердца нужна для полного заряда", "Шапка Астронома", "ru")
	EID:addCollectible(CustomCollectibles.BOTTOMLESS_BAG, "В течение 4 секунд все ближащие снаряды всасываются в мешок #Удерживайте кнопку стрельбы, чтобы выпустить все всосанные снаряды в соответствующем направлении #Снаряды становятся самонаводящимися", "Бездонный Мешок", "ru")
	EID:addCollectible(CustomCollectibles.CROSS_OF_CHAOS, "Враги, которые приближаются к вам, становятся ослабленными; ваши слезы также могут ослабить их #Ослабленные враги теряют свою скорость со временем и умирают через 16 секунд после ее потери #Когда ослабленные враги умирают, они выпускают фонтан замедляющихся черных слез", "Крест Хаоса", "ru")
	EID:addCollectible(CustomCollectibles.REJECTION, "При использовании уничтожает всех спутников на одну комнату и бросает их в виде большого пронзающего ядовитого шара в направлении вашей стрельбы #Формула урона: ваш урон * 4 *количество спутников #Пассивно дает фамильяра, который не стреляет слезами, но наносит 2,5 контактного урона врагам.", "Отторжение", "ru")
	EID:addCollectible(CustomCollectibles.AUCTION_GAVEL, "Создает предмет из пула комнаты который можно купить # Его цена будет меняться случайно 5 раз в секунду #Цена меняется случайно, но в целом увеличивается, пока не достигнет 99 монет #Если вы выйдете из комнаты, предмет исчезнет", "Молоток для Аукциона", "ru")
	EID:addCollectible(CustomCollectibles.SOUL_BOND, "Приковывайте себя к случайному врагу астральной цепью и замораживайте их # Цепь наносит сильный контактный урон врагам # Если вы отойдете слишком далеко от прикованного врага, цепь разорвется #Прикованные враги имеют 33% шанс уронить синие сердце при смерти", "Связь Душ", "ru")
	EID:addCollectible(CustomCollectibles.ANGELS_WINGS, "{{ArrowUp}} +0,3 к скорости выстрела  #Ваши слезы заменяются пронзающими перьями, которые наносят больше урона, чем больше они пролетают # Двойное нажатие на кнопку выстрела, чтобы использовать одну из атак Догмы #Имеет 6 секунд перезарядки", "Ангельские Крылья", "ru")

	EID:addTrinket(CustomTrinkets.BASEMENT_KEY, "{{ChestRoom}} Золотые Сундуки имеют 12.5% шанс стать Старым Сундуком", "Ключ от Подвала", "ru")
	EID:addTrinket(CustomTrinkets.KEY_TO_THE_HEART, "У каждого врага есть шанс создать Кожанный Сундук после смерти #Кожанные Сундуки могут содержать 1-4 {{Heart}} сердца/{{Pill}} таблетки или случайный предмет, связанный с телом", "Ключ к Сердцу", "ru")
	EID:addTrinket(CustomTrinkets.JUDAS_KISS, "Враги, прикасающиеся к вам, будут атакованы другими врагами (похожий на эффект {{Collectible618}} Тухлого Помидора)", "Поцелуй Иуды", "ru")
	EID:addTrinket(CustomTrinkets.TRICK_PENNY, "Трата монет, бомб или ключей на автоматы, попрошаек или запертые сундуки имеет 17 % шанс не вычесть их из вашего инвентаря", "Трюк с Монеткой", "ru")
	EID:addTrinket(CustomTrinkets.SLEIGHT_OF_HAND, "После появления каждая монета имеет 20% шанс быть повышена до более высокой стоимости: #пенни->двойной пенни->липкий никель->никель-> десятник->счастливый пенни->золотой пенни", "Ловкость Рук", "ru")
	EID:addTrinket(CustomTrinkets.GREEDS_HEART, "Дает вам один пустой контейнер монет #Оно тратится раньше, чем обычные сердца, и может быть пополнено только путем прямого подбирания монеток", "Сердце Жадности", "ru")
	EID:addTrinket(CustomTrinkets.ANGELS_CROWN, "Во всех новых Сокровищницах будет продаваться предмет ангела вместо обычного предмета #Ангелы не оставят части ключа при битве!", "Ангельская Корона", "ru")
	EID:addTrinket(CustomTrinkets.MAGIC_SWORD, "{{ArrowUp}} Удваивает ваш урон #Ломается, когда вы получаете урон #{{ArrowUp}} Наличие Клейкой Ленты предотвращает поломку", "Магический Меч", "ru")
	EID:addTrinket(CustomTrinkets.WAIT_NO, "Ничего не делает", "О Нет!", "ru")
	EID:addTrinket(CustomTrinkets.EDENS_LOCK, "При получении урона один из ваших предметов меняется на другой случайный предмет", "Локон Эдема", "ru")
	EID:addTrinket(CustomTrinkets.PIECE_OF_CHALK, "При входе в комнату вы оставляете под собой след из порошка в течение 5 секунд #Враги, проходящие по порошку, будут отброшены назад", "Кусок Мела", "ru")
	EID:addTrinket(CustomTrinkets.ADAMS_RIB, "При смерти, воскрешает вас за Еву", "Ребро Адама", "ru")
	EID:addTrinket(CustomTrinkets.NIGHT_SOIL, "75% шанс предотвратить проклятия при входе на новый этаж", "Ночное Золото", "ru")
	EID:addTrinket(CustomTrinkets.BONE_MEAL, "В начале каждого этажа дает: #{{ArrowUp}} +10% Урона #{{ArrowUp}} Увеличение размера игрока #Урон и размер сохраняются если вы выбросите этот брелок", "Костная Мука", "ru")
	EID:addTrinket(CustomTrinkets.TORN_PAGE, "Усиливает эффекты книг #Этот брелок может появится в библиотеках с шансом 33%", "Порванная Страница", "ru")
	EID:addTrinket(CustomTrinkets.EMPTY_PAGE, "Книги активируют случайный активный предмет при использовании  #Этот брелок может появится в библиотеках с шансом 33%", "Пустая Страница", "ru")
	EID:addTrinket(CustomTrinkets.BABY_SHOES, "Уменьшает врагов на 20% #Также работает на боссах", "Детские Ботиночки", "ru")
	EID:addTrinket(CustomTrinkets.KEY_KNIFE, "С шансом 5% активирует Темные Искусства когда вы получаете урон #Увеличивает шанс пояяления Черных Сундуков", "Нож Ключ", "ru")
	

	EID:addCard(CustomConsumables.SPINDOWN_DICE_SHARD, "Активирует эффект {{Collectible723}} Кубика с Вычетом", "Осколок Кубика с Вычетом", "ru")
	EID:addCard(CustomConsumables.RED_RUNE, "Наносит урон всем врагам в комнате, превращает все пьедесталы с предметами в красную саранчу и превращает пикапы в случайную саранчу с вероятностью 50%", "Красная Руна", "ru")
	EID:addCard(CustomConsumables.NEEDLE_AND_THREAD, "Убирает одно Сломанное Сердце и дает один {{Heart}} Контейнер Сердца", "Игла и Нитка", "ru")
	EID:addCard(CustomConsumables.QUEEN_OF_DIAMONDS, "Создает 1-12 {{Coin}} случайных монет", "Дама Бубен", "ru")
	EID:addCard(CustomConsumables.KING_OF_SPADES, "Вы теряете все свои ключи и создаете количество пикапов, пропорциональное количеству потерянных ключей #Для брелка требуется не менее 12 {{Key}} ключей и не менее 28 для предмета #Если у вас есть {{GoldenKey}} Золотой Ключ, он тоже удаляется и значительно увеличивает количество пикапов", "Король Пик", "ru")
	EID:addCard(CustomConsumables.KING_OF_CLUBS, "Вы теряете все свои бомбы и создаете количество пикапов, пропорциональное количеству потерянных бомб #Для брелка требуется не менее 12 {{Bomb}} бомб и не менее 28 для предмета #Если у вас есть {{GoldenBomb}} Золотая Бомба, он тоже удаляется и значительно увеличивает количество пикапов", "Король Треф", "ru")
	EID:addCard(CustomConsumables.KING_OF_DIAMONDS, "Вы теряете все свои монеты и создаете количество пикапов, пропорциональное количеству потерянных монет #Для брелка требуется не менее 12 {{Coin}} монет и не менее 28 для предмета", "Король Бубен", "ru")
	EID:addCard(CustomConsumables.BAG_TISSUE, "Все пикапы в комнате уничтожаются, и 8 самых ценных пикапов формируют качество предмета на основе их общей ценности; затем появляется предмет такого качества #Самые ценные пикапы - самые редкие, например {{EternalHeart}} Вечные сердца или {{Battery}} Мега Батареи #{{Warning}} При использовании в комнате с менее чем 8 пикапами предмет не появится!", "Ткань", "ru")
	EID:addCard(CustomConsumables.JOKER_Q, "Телепортирует вас в {{SuperSecretRoom}} Черный Рынок", "Джокер?", "ru")
	EID:addCard(CustomConsumables.UNO_REVERSE_CARD, "Активирует эффект {{Collectible422}} Светящихся Песочных Часов", "Обратная Карта", "ru")
	EID:addCard(CustomConsumables.LOADED_DICE, "{{ArrowUp}} +10 к удаче на одну комнату", "Шулерские Кости", "ru")
	EID:addCard(CustomConsumables.BEDSIDE_QUEEN, "Создает 1-12 {{Key}} случайных ключей", "Дама Пик", "ru")
	EID:addCard(CustomConsumables.QUEEN_OF_CLUBS, "Создает 1-12 {{Bomb}} случайных бомб", "Дама Треф", "ru")
	EID:addCard(CustomConsumables.JACK_OF_CLUBS, "Бомбы будут чаще падать после прохождение комнат на этом этажа, и качество бомб увеличится", "Валет Треф", "ru")
	EID:addCard(CustomConsumables.JACK_OF_DIAMONDS, "Монеты будут чаще падать после прохождение комнат на этом этажа, и качество монет увеличится", "Валет Бубен", "ru")
	EID:addCard(CustomConsumables.JACK_OF_SPADES, "Ключи будут чаще падать после прохождение комнат на этом этажа, и качество ключей увеличится", "Валет Пик", "ru")
	EID:addCard(CustomConsumables.JACK_OF_HEARTS, "Сердца будут чаще падать после прохождение комнат на этом этажа, и качество сердец увеличится", "Валет Червей", "ru")
	EID:addCard(CustomConsumables.QUASAR_SHARD, "Поглощает все предметы на пьедесталах в комнате и дает 3 огонька {{Collectible712}} Лемегетона за каждый поглощенный предмет", "Осколок Квазара", "ru")
	EID:addCard(CustomConsumables.BUSINESS_CARD, "Активирует эффект {{Collectible687}} Искателя Друзей", "Визитная Карточка", "ru")
	EID:addCard(CustomConsumables.SACRIFICIAL_BLOOD, "{{ArrowUp}} Дает +1,25 урона, который истощается в течение 20 секунд #{{ArrowUp}} Исцеляет вас на одно Красное Сердце, если у вас есть Церемониальные Роба #{{Warning}} Чем больше крови вы использовали впоследствии, тем быстрее понижается урон", "Жертвенная Кровь", "ru")
	EID:addCard(CustomConsumables.LIBRARY_CARD, "Активирует эффект случайной книги", "Читательский Билет", "ru")
	EID:addCard(CustomConsumables.FLY_PAPER, "Создает 8 мух схожие с предметом {{Collectible693}} Рой", "Липучка", "ru")
	EID:addCard(CustomConsumables.MOMS_ID , "Очаровывает всех врагов в комнате", "Мамино Удостоверение", "ru")
	EID:addCard(CustomConsumables.FUNERAL_SERVICES , "Создает Старый Сундук", "Похоронное Бюро", "ru")
	EID:addCard(CustomConsumables.ANTIMATERIAL_CARD , "Можно кинуть как Карту Хаоса #При попадании стирает врага до конца забега", "Антиматериальная Карта", "ru")
	EID:addCard(CustomConsumables.FIEND_FIRE, "Пожертвуйте своими расходниками для массового уничтожения комнаты #7-40 итого: враги получают 15 урона и горят в течение 4 секунд #41-80 итого: начальный урон, урон от горения и продолжительность горения удваиваются; уничтожает препятствия вокруг вас #81+ итого: урон от горения и продолжительность горения увеличиваются в четыре раза; Дает эффект предмета Мама Мега на одну комнаты", "Дьявольский Огонь", "ru")
	EID:addCard(CustomConsumables.DEMON_FORM, "{{ArrowUp}} Дает 0.15 урона когда вы входите в незачищенную комнату #Бонус исчезает при переходе на следующий этаж", "Демоническая Форма", "ru")
	EID:addCard(CustomConsumables.VALENTINES_CARD , "Можно кинуть как Хаос Карту #Если карта попадает во врага, он становится дружелюбным и создает красное сердце", "Валентинка", "ru")

	EID:addPill(CustomPills.ESTROGEN, "Превращает все ваши {{Heart}} сердца в блебиков #Оставляет вас по крайней мере с одним красным сердцем, не убирает сердца души/черные сердца", "Эстроген", "ru")
	EID:addPill(CustomPills.LAXATIVE, "Заставляет вас стрелять кукурузой сзади в течение 3 секунд", "Слабительное", "ru")
	EID:addPill(CustomPills.PHANTOM_PAINS, "Вы получаете фальшивый урон и получаете его снова через 15 и 30 секунд", "Фантомная Боль", "ru")
	EID:addPill(CustomPills.YUCK, "Создает гнилое сердце #В течение 30 секунд, каждое взятое красное сердце будет создавать синих мух", "Фу!", "ru")
	EID:addPill(CustomPills.YUM, "Создает красное сердце #В течение 30 секунд, каждое взятое красное сердце даст вам небольшое постоянное увеличение случайной характеристики, похожий на эффект {{Collectible671}} Карамельного Сердца", "Ням!", "ru")
end

								---------------------
								--- ENCYCLOPEDIA  ---
								---------------------

if Encyclopedia then	
	local ItemsWiki = {
		[CustomCollectibles.ORDINARY_LIFE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Tears up"},
				{str = "Spawns an additional Mom/Dad related item in Treasure rooms alongside the presented items; only one item can be taken"},
			},
		},
		[CustomCollectibles.COOKIE_CUTTER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Gives you one heart container and one broken heart "},
				{str = "Having 12 broken hearts kills you!"},
			},
		},
		[CustomCollectibles.SINNERS_HEART] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "+2 black hearts "},
				{str = "Damage +2 then x1.5"},
				{str = "Grants +2 range and -0.2 shotspeed "},
				{str = "Grants spectral and piercing tears"},
			},
		},
		[CustomCollectibles.RUBIKS_CUBR] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "After each use, has a 5% (100% on 20-th use) chance to be 'solved', removed from the player and be replaced with a Magic Cube item"},
			},
		},
		[CustomCollectibles.MAGIC_CUBE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Rerolls item pedestals "},
				{str = "Rerolled items can be drawn from any item pool"},
			},
		},
		[CustomCollectibles.MAGIC_PEN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Double tap shooting button to spew a line of  creep in the direction you're firing "},
				{str = "Random permanent status effects is applied to enemies walking over that creep "},
				{str = "Has a 4 seconds cooldown"},
			},
		},
		[CustomCollectibles.MARK_OF_CAIN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "On death, if you have any CustomFamiliars, removes them instead and revives you "},
				{str = "On revival, you keep your heart containers, gain +".. tostring(CustomStatups.MARKCAIN_DMG) .. " DMG for each consumed familiar and gain invincibility"},
				{str = "Works only once!"},
			},
		},
		[CustomCollectibles.TEMPER_TANTRUM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "25% chance to enter Berserk state when taking damage "},
				{str = "While in this state, every enemy damaged has a 10% chance to be erased for the rest of the run"},
			},
		},
		[CustomCollectibles.BAG_O_TRASH] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "A familiar that creates blue flies upon clearing a room "},
				{str = "Blocks enemy projectiles, and after blocking it has a chance to be destroyed and drop Breakfast or Nightsoil trinket "},
				{str = "The more floors it is not destroyed, the more flies it spawns"},
			},
		},
		[CustomCollectibles.CHERUBIM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "A familiar that rapidly shoots tears with Godhead aura"},
			},
		},
		[CustomCollectibles.CHERRY_FRIENDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Killing an enemy has a 20% chance to drop cherry familiar on the ground "},
				{str = "Those cherries emit a charming fart when an enemy walks over them, and drop half a heart when a room is cleared"},
			},
		},
		[CustomCollectibles.BLACK_DOLL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon entering a new room, all enemies will be split in pairs. Dealing damage to one enemy in each pair will deal 60% of that damage to another enemy in that pair"},
			},
		},
		[CustomCollectibles.BIRD_OF_HOPE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon dying you turn into invincible ghost and a bird flies out of room center in a random direction. Catching the bird in 5 seconds will save you and get you back to your death spot, otherwise you will die "},
				{str = "Every time you die, the bird will fly faster and faster, making it harder to catch her"},
			},
		},
		[CustomCollectibles.ENRAGED_SOUL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Double tap shooting button to launch a ghost familiar in the direction you are firing "},
				{str = "The ghost will latch onto the first enemy it collides with, dealing damage over time for 7 seconds or until that enemy is killed "},
				{str = "The ghost's damage per hit starts at 7 and increases each floor "},
				{str = "The ghost can latch onto bosses aswell "},
				{str = "Has a 7 seconds cooldown"},
			},
		},
		[CustomCollectibles.CEREMONIAL_BLADE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "When shooting, 7% chance to launch a piercing dagger that does no damage, but inflicts bleed on enemies"},
				{str = "All enemies that die while bleeding will drop Sacrificial Blood Consumable that gives you temporary DMG up"},
			},
		},
		[CustomCollectibles.CEILING_WITH_THE_STARS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Grants you two Lemegeton wisps at the beginning of each floor and when sleeping in bed"},
			},
		},
		[CustomCollectibles.QUASAR] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Consumes all item pedestals in the room and gives you 3 Lemegeton wisps for each item consumed"},
			},
		},
		[CustomCollectibles.TWO_PLUS_ONE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Every third shop item on the current floor will cost 1  penny "},
				{str = "Buying two items with hearts in one room makes all other items free"},
			},
		},
		[CustomCollectibles.RED_MAP] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Reveals location of Ultra Secret Room on all subsequent floors "},
				{str = "Any trinket left in a boss or treasure room will turn into Cracked Key, unless this is your first visit in such room"},
			},
		},
		[CustomCollectibles.CHEESE_GRATER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Removes one red heart container and gives you  +".. tostring(CustomStatups.GRATER_DMG) .. " Damage up and 3 Minisaacs"},
			},
		},
		[CustomCollectibles.DNA_REDACTOR] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "CustomPills now have additional effects based on their color"},
			},
		},
		[CustomCollectibles.TOWER_OF_BABEL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Destroys all obstacles in the current room and applies confusion to enemies in small radius around you "},
				{str = "Also blows the doors open and opens secret room entrances"},
			},
		},
		[CustomCollectibles.BLESS_OF_THE_DEAD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Prevents curses from appearing for the rest of the run "},
				{str = "Preventing a curse grants you  +".. tostring(CustomStatups.BLESS_DMG) .. " Damage up"},
			},
		},
		[CustomCollectibles.TANK_BOYS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 2 Toy Tanks CustomFamiliars that roam around the room and attack enemies that are in their line of sight "},
				{str = "Green tank: rapidly shoots bullets at enemies from a further distance and moves more quickly "},
				{str = "Red tank: shoots rockets at enemies at a close range, moves slower"},
			},
		},
		[CustomCollectibles.GUSTY_BLOOD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Killing enemies grants you  tears and speed up "},
				{str = "The bonus is reset when entering a new room"},
			},
		},
		[CustomCollectibles.RED_BOMBER] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "+5 bombs "},
				{str = "Grants explosion immunity "},
				{str = "Allows you to throw your bombs instead of placing them on the ground"},
			},
		},
		[CustomCollectibles.MOTHERS_LOVE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Grants you stat boosts for each familiar you own"},
				{str = "Some CustomFamiliars grant greater stat boosts, and some do not grant them at all (e.g. blue flies, dips or Isaac's body parts)"},
			},
		},
		[CustomCollectibles.CAT_IN_A_BOX] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "When entering a room with enemies, their health is halved for the first 3 seconds, and then restored back to full "},
				{str = "Doesn't work on bosses or minibosses"},
			},
		},
		[CustomCollectibles.BOOK_OF_GENESIS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Removes a random item and spawns 3 items of the same quality "},
				{str = "Only one item can be taken "},
				{str = "Can't remove or spawn quest items"},
			},
		},
		[CustomCollectibles.SCALPEL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Makes you shoot tears in the opposite direction "},
				{str = "From the front, you will frequently shoot bloody tears that deal x0.66 of your damage "},
				{str = "All other weapon types will still be fired from the front as well"},
			},
		},
		[CustomCollectibles.KEEPERS_PENNY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns a golden penny upon entering a new floor "},
				{str = "Shops will now sell 1-4 additional items that are drawn from shop, treasure or boss itempools"},
				{str = "If the shop is a Greed fight, it instead spawns 3-4 items when the miniboss dies"}
			},
		},
		[CustomCollectibles.NERVE_PINCH] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Shooting or moving for 8 seconds will trigger a nerve pinch "},
				{str = "You take fake damage and gain a permanent " .. tostring(CustomStatups.NERVEPINCH_SPEED) .. " speed down when that happens "},
				{str = "However, there is a 80% chance to activate your active item for free, even if it's uncharged "},
				{str = "One-time use and infinite use actives cannot be used that way"},
			},
		},
		[CustomCollectibles.BLOOD_VESSELS[1]] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Taking damage doesn't actually hurt the player, instead filling the blood vessel "},
				{str = "This can be repeated 6 times until the vessel is full "},
				{str = "Once it's full, using it or taking damage will empty it and deal 3 and 3.5 hearts of damage to the player, respectively"},
			},
		},
		[CustomCollectibles.SIBLING_RIVALRY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Orbital that switches between 2 different states every 15 seconds:"},
				{str = "Two orbitals that quickly rotate around Isaac"},
				{str = "One orbital that rotates slower and closer to Isaac, and periodically shoots teeth in random directions and spawns blood creep underneath it"},
				{str = "All orbitals block enemy shots and do contact damage"},
			},
		},
		[CustomCollectibles.RED_KING] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "After defeating a boss, red crawlspace will appear in a middle of a room"},
				{str = "Entering the crawlspace brings you to another bossfight of high difficulty. Victory rewards you a red item (from Ultra secret room pool)"},
				{str = "The crawlspace can be entered only once, but you can enter it whenever you want, not necessarily after defeating the main floor boss"},
				{str = "Bosses from chapters 2 and onward of the main path can be encountered; also includes a lot of double trouble bossfights"},
			},
		},
		[CustomCollectibles.STARGAZERS_HAT] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Summons the Stargazer beggar"},
				{str = "Can only be charged with soul hearts, similar to Alabaster Box"},
				{str = "2 soul hearts needed for full charge"},
			},
		},
		[CustomCollectibles.BOTTOMLESS_BAG] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon use, holds the bag in the air"},
				{str = "For 4 seconds, all nearby projectiles are sucked into the bag"},
				{str = "Hold the shooting button to release all sucked projecties as homing tears in the matching direction after 4 seconds"},
				{str = "Tears released by the bag inherit all your tear effects (e.g. they are explosive if you have Ipecac)"},
				{str = "If the player doesn't hold a shooting button, the reflected tears are shot downwards"},
			},
		},
		[CustomCollectibles.CROSS_OF_CHAOS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Enemies that come close to you become crippled"},
				{str = "Crippled enemies lose their speed overtime, and die afer 16 seconds of losing it"},
				{str = "When crippled enemies die, they release a fountain of slowing black tears"},
				{str = "Your tears also have a chance to cripple enemies. Base chance is 2% and it maxes out at 7% at 10 luck"},
			},
		},
		[CustomCollectibles.REJECTION] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "On use, consume all your follower familiars and throw them as big piercing poisonous gut ball in your firing direction"},
				{str = "Damage formula: your dmg * 4 * number of consumed familiars"},
				{str = "Passively grants a familiar that doesn't shoot tears, but deals 2.5 contact damage to enemies"},
			},
		},
		[CustomCollectibles.AUCTION_GAVEL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns an item from the room's pool for sale"},
				{str = "Its price will change rougly 5 times a second"},
				{str = "The price is random, but generally increases over time until it reaches $99"},
				{str = "If you leave and re-enter the room, the item disappears"},
			},
		},
		[CustomCollectibles.SOUL_BOND] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Chain yourself to a random enemy with an astral chain and freeze them"},
				{str = "The chain deals contact damage to enemies"},
				{str = "Going too far away from chained enemy will break the chain"},
				{str = "Chained enemies have a 50% chance to drop half a soul heart when killed"},
			},
		},
	}
	
	local TrinketsWiki = {
		[CustomTrinkets.BASEMENT_KEY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "While held, every Golden Chest has a 12.5% chance to be replaced with Old Chest"},
			},
		},
		[CustomTrinkets.KEY_TO_THE_HEART] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "While held, every enemy has a chance to drop Flesh Chest upon death"},
				{str = "Flesh Chests hurt the player for half a heart when opened; this damage prioritizes red hearts"},
				{str = "Flesh Chests contain 1-4 pills/hearts or a random body-related item"},
			},
		},
		[CustomTrinkets.JUDAS_KISS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Enemies touching you become targeted by other enemies (effect of Rotten Tomato item)"},
			},
		},
		[CustomTrinkets.TRICK_PENNY] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Using coin, bomb or key on slots, beggars or locked chests has a 17% chance to not subtract it from your inventory count"},
			},
		},
		[CustomTrinkets.SLEIGHT_OF_HAND] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon spawning, every coin has a 20% chance to be upgraded to a higher value"},
				{str = "The upgrade is as follows: penny -> doublepack pennies -> sticky nickel -> nickel -> dime -> lucky penny -> golden penny"},
			},
		},
		[CustomTrinkets.GREEDS_HEART] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Gives you one empty coin heart"},
				{str = "It is depleted before any of your normal hearts and can only be refilled by directly picking up money"},
			},
		},
		[CustomTrinkets.ANGELS_CROWN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "All new treasure rooms will have an angel item for sale instead of a normal item"},
				{str = "Angels spawned from statues will not drop Key Pieces!"},
				{str = "Angel items reroll into items from a treasure room pool"}
			},
		},
		[CustomTrinkets.MAGIC_SWORD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "x2 DMG up while held "},
				{str = "Breaks when you take damage"},
				{str = "Having Duct Tape prevents it from breaking"},
			},
		},
		[CustomTrinkets.WAIT_NO] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Does nothing, it's broken"},
			},
		},
		[CustomTrinkets.EDENS_LOCK] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Upon taking damage, one of your items rerolls into another random item"},
				{str = "Doesn't take away nor give you story items"},
			},
		},
		[CustomTrinkets.PIECE_OF_CHALK] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "When entering uncleared room, you will leave a trail of powder underneath for 5 seconds"},
				{str = "Enemies walking over the powder will be significantly slowed down"},
				{str = "The powder lasts for 10 seconds"},
			},
		},
		[CustomTrinkets.ADAMS_RIB] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Revives you as Eve when you die"},
				{str = "The Eve character receives 3 soul hearts and a Whore of Babylon item"}
			},
		},
		[CustomTrinkets.NIGHT_SOIL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "75% chance to prevent a curse when entering a new floor"},
			},
		},
		[CustomTrinkets.BONE_MEAL] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "At the beginning of every new floor, grants:"},
				{str = "+10% DMG up"},
				{str = "Size increase "},
				{str = "Both damage and size up stay if you drop the trinket"},
			},
		},
		[CustomTrinkets.TORN_PAGE] = {
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
		[CustomTrinkets.EMPTY_PAGE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Books now activate a random active item on use "},
				{str = "Doesn't work on How to Jump and doesn't proc dice and items that hurt or kill you"},
				{str = "Apart from natural spawns, this trinket has a 33% chance to spawn in libraries"},
			},
		},
		[CustomTrinkets.BABY_SHOES] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Reduces the size of all enemies by 20%"},
				{str = "This affects both sprite and hitbox"},
				{str = "Affects bosses too"},
			},
		},
		[CustomTrinkets.KEY_KNIFE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "5% chance to activate Dark Arts effect when taking damage "},
				{str = "Increases the spawn rates of Black chests in Devil rooms"},
			},
		},
	}
	
	local PillsWiki = {
		[CustomPills.ESTROGEN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Turns all your red health into blood clots "},
				{str = "Leaves you at one red heart, doesn't affect soul/black hearts"},
			},
		},
		[CustomPills.LAXATIVE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Makes you shoot out corn tears from behind for 3 seconds"},
			},
		},
		[CustomPills.PHANTOM_PAINS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Makes Isaac take fake damage on pill use, then 15 and 30 seconds after"},
			},
		},
		[CustomPills.YUCK] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns a rotten heart "},
				{str = "For 30 seconds, every picked up red heart will spawn blue flies"},
			},
		},
		[CustomPills.YUM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns a red heart "},
				{str = "For 30 seconds, every picked up red heart will grant you small permanent stat upgrades, similar to Candy Heart effect"},
			},
		},
	}

	local PillsColors = {
		[CustomPills.ESTROGEN] = 9,
		[CustomPills.LAXATIVE] = 10,
		[CustomPills.PHANTOM_PAINS] = 10,
		[CustomPills.YUCK] = 9,
		[CustomPills.YUM] = 9
	}
	
	local itemPools = {
		[CustomCollectibles.ORDINARY_LIFE] = {Encyclopedia.ItemPools.POOL_BOSS},
		[CustomCollectibles.COOKIE_CUTTER] = {Encyclopedia.ItemPools.POOL_DEMON_BEGGAR, Encyclopedia.ItemPools.POOL_CURSE},
		[CustomCollectibles.RUBIKS_CUBR] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_CRANE_GAME},
		[CustomCollectibles.MAGIC_PEN] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_CRANE_GAME},
		[CustomCollectibles.MARK_OF_CAIN] = {Encyclopedia.ItemPools.POOL_CURSE, Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.TEMPER_TANTRUM] = {Encyclopedia.ItemPools.POOL_SECRET, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.BAG_O_TRASH] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BEGGAR, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[CustomCollectibles.CHERUBIM] = {Encyclopedia.ItemPools.POOL_ANGEL, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[CustomCollectibles.CHERRY_FRIENDS] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.BLACK_DOLL] = {Encyclopedia.ItemPools.POOL_CURSE, Encyclopedia.ItemPools.POOL_RED_CHEST},
		[CustomCollectibles.BIRD_OF_HOPE] = {Encyclopedia.ItemPools.POOL_ANGEL},
		[CustomCollectibles.ENRAGED_SOUL] = {Encyclopedia.ItemPools.POOL_DEVIL},
		[CustomCollectibles.CEREMONIAL_BLADE] = {Encyclopedia.ItemPools.POOL_DEVIL},
		[CustomCollectibles.CEILING_WITH_THE_STARS] = {Encyclopedia.ItemPools.POOL_SHOP},
		[CustomCollectibles.QUASAR] = {Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ANGEL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.TWO_PLUS_ONE] = {Encyclopedia.ItemPools.POOL_SHOP, Encyclopedia.ItemPools.POOL_SECRET},
		[CustomCollectibles.RED_MAP] = {Encyclopedia.ItemPools.POOL_SECRET, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.SINNERS_HEART] = {Encyclopedia.ItemPools.POOL_DEVIL},
		[CustomCollectibles.CHEESE_GRATER] = {Encyclopedia.ItemPools.POOL_SHOP},
		[CustomCollectibles.DNA_REDACTOR] = {Encyclopedia.ItemPools.POOL_SECRET},
		[CustomCollectibles.TOWER_OF_BABEL] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_CRANE_GAME},
		[CustomCollectibles.BLESS_OF_THE_DEAD] = {Encyclopedia.ItemPools.POOL_SECRET},
		[CustomCollectibles.TANK_BOYS] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[CustomCollectibles.GUSTY_BLOOD] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.RED_BOMBER] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BOMB_BUM, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.MOTHERS_LOVE] = {Encyclopedia.ItemPools.POOL_SHOP, Encyclopedia.ItemPools.POOL_BEGGAR, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.CAT_IN_A_BOX] = {Encyclopedia.ItemPools.POOL_TREASURE},
		[CustomCollectibles.BOOK_OF_GENESIS] = {Encyclopedia.ItemPools.POOL_ANGEL, Encyclopedia.ItemPools.POOL_LIBRARY},
		[CustomCollectibles.SCALPEL] = {Encyclopedia.ItemPools.POOL_DEMON_BEGGAR, Encyclopedia.ItemPools.POOL_RED_CHEST},
		[CustomCollectibles.KEEPERS_PENNY] = {Encyclopedia.ItemPools.POOL_SHOP, Encyclopedia.ItemPools.POOL_SECRET},
		[CustomCollectibles.NERVE_PINCH] = {Encyclopedia.ItemPools.POOL_TREASURE},
		[CustomCollectibles.BLOOD_VESSELS[1]] = {Encyclopedia.ItemPools.POOL_DEMON_BEGGAR, Encyclopedia.ItemPools.POOL_CURSE},
		[CustomCollectibles.SIBLING_RIVALRY] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_BABY_SHOP},
		[CustomCollectibles.RED_KING] = {Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.STARGAZERS_HAT] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_SECRET},
		[CustomCollectibles.BOTTOMLESS_BAG] = {Encyclopedia.ItemPools.POOL_SECRET},
		[CustomCollectibles.CROSS_OF_CHAOS] = {Encyclopedia.ItemPools.POOL_DEVIL, Encyclopedia.ItemPools.POOL_ULTRA_SECRET},
		[CustomCollectibles.REJECTION] = {Encyclopedia.ItemPools.POOL_TREASURE, Encyclopedia.ItemPools.POOL_ROTTEN_BEGGAR},
		[CustomCollectibles.AUCTION_GAVEL] = {Encyclopedia.ItemPools.POOL_SHOP, Encyclopedia.ItemPools.POOL_CRANE_GAME, Encyclopedia.ItemPools.POOL_WOODEN_CHEST},
		[CustomCollectibles.SOUL_BOND] = {Encyclopedia.ItemPools.POOL_ANGEL},
	}

	local CardsWiki = {
		[CustomConsumables.SPINDOWN_DICE_SHARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Invokes the effect of Spindown Dice"},
			},
		},
		[CustomConsumables.RED_RUNE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Damages all enemies in a room, turns item pedestals into red permanent locusts and turns CustomPickups into random locusts with a 50% chance"},
			},
		},
		[CustomConsumables.NEEDLE_AND_THREAD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Removes one broken heart and grants one full heart container"},
			},
		},
		[CustomConsumables.QUEEN_OF_DIAMONDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 1-12 random coins"},
				{str = "Coins could be nickels or dimes too"}
			},
		},
		[CustomConsumables.KING_OF_SPADES] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Lose all your keys (but no more than 33) and spawn a number of CustomPickups proportional to the amount of keys lost"},
				{str = "At least 9 keys is needed for a trinket, and at least 21 for an item "},
				{str = "If Isaac has Golden key, it is removed too and significantly increases total value"},
			},
		},
		[CustomConsumables.KING_OF_CLUBS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Lose all your bombs (but no more than 33) and spawn a number of CustomPickups proportional to the amount of bombs lost"},
				{str = "At least 9 bombs is needed for a trinket, and at least 21 for an item"},
				{str = "If Isaac has Golden bomb, it is removed too and significantly increases total value"},
			},
		},
		[CustomConsumables.KING_OF_DIAMONDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Lose all your coins (but no more than 66) and spawn a number of CustomPickups proportional to the amount of coins lost"},
				{str = "At least 24 coins is needed for a trinket, and at least 54 for an item"},
			},
		},
		[CustomConsumables.BAG_TISSUE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "All CustomPickups in a room are destroyed, and 8 most valuables CustomPickups form an item quality based on their total weight; the item of such quality is then spawned "},
				{str = "The most valuable CustomPickups are the rarest ones, e.g. eternal hearts or mega batteries"},
				{str = "If used in a room with less then 8 CustomPickups, no item will spawn!"},
			},
		},
		[CustomConsumables.JOKER_Q] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Teleports Isaac to a Black Market"},
			},
		},
		[CustomConsumables.UNO_REVERSE_CARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Invokes the effect of Glowing Hourglass"},
			},
		},
		[CustomConsumables.LOADED_DICE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "grants 10 Luck for the current room"},
			},
		},
		[CustomConsumables.BEDSIDE_QUEEN] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 1-12 random keys "},
				{str = "There is a small chance to spawn a charged key"},
			},
		},
		[CustomConsumables.QUEEN_OF_CLUBS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns 1-12 random bombs "},
				{str = "There is a small chance to spawn a double-pack bomb"},
			},
		},
		[CustomConsumables.JACK_OF_CLUBS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Bombs will drop more often from clearing rooms for current floor, and the average quality of bombs is increased"},
			},
		},
		[CustomConsumables.JACK_OF_DIAMONDS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Coins will drop more often from clearing rooms for current floor, and the average quality of coins is increased"},
			},
		},
		[CustomConsumables.JACK_OF_SPADES] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Keys will drop more often from clearing rooms for current floor, and the average quality of keys is increased"},
			},
		},
		[CustomConsumables.JACK_OF_HEARTS] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Hearts will drop more often from clearing rooms for current floor, and the average quality of hearts is increased"},
			},
		},
		[CustomConsumables.QUASAR_SHARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Damages all enemies in a room and turns every item pedestal into 3 Lemegeton wisps"},
			},
		},
		[CustomConsumables.BUSINESS_CARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Summons a random monster, like ones from Friend Finder"},
			},
		},
		[CustomConsumables.SACRIFICIAL_BLOOD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Gives +1.25 DMG up that depletes over the span of 20 seconds"},
				{str = "Stackable"},
				{str = "Heals you for one red heart if you have Ceremonial Robes "},
				{str = "Damage depletes quicker the more Blood you used subsequently"},
			},
		},
		[CustomConsumables.LIBRARY_CARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Activates a random book effect"},
			},
		},
		[CustomConsumables.MOMS_ID] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Charms all enemies in the current room"},
			},
		},
		[CustomConsumables.FUNERAL_SERVICES ] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Spawns an Old Chest"},
			},
		},
		[CustomConsumables.ANTIMATERIAL_CARD] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Can be thrown similarly to Chaos Card"},
				{str = "If the card touches an enemy, that enemy is erased for the rest of the run"},
			},
		},
		[CustomConsumables.FIEND_FIRE] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Sacrifice your consumables for mass room destruction"},
				{str = "7-40 total: enemies take 15 damage and burn for 4 seconds"},
				{str = "41-80 total: the initital damage, the burning damage and burning duration are doubled; destroys obstacles around you"},
				{str = "80+ total: the burning damage and burning duration are quadrupled; produces a Mama Mega explosion"},
			},
		},
		[CustomConsumables.DEMON_FORM] = {
			{
				{str = "Effects", fsize = 2, clr = 3, halign = 0},
				{str = "Increases your damage by 0.15 for every new uncleared room you enter"},
				{str = "The boost disappears when entering a new floor"},
			},
		},
	}
	
	local spriteToCard = {
		[CustomConsumables.SPINDOWN_DICE_SHARD] = "Spindown Dice Shard",
		[CustomConsumables.RED_RUNE] = "Red Rune",
		[CustomConsumables.NEEDLE_AND_THREAD] = "Needle and Thread",
		[CustomConsumables.QUEEN_OF_DIAMONDS] = "Queen of Diamonds",
		[CustomConsumables.KING_OF_SPADES] = "King of Spades",
		[CustomConsumables.KING_OF_CLUBS] = "King of Clubs",
		[CustomConsumables.KING_OF_DIAMONDS] = "King of Diamonds",
		[CustomConsumables.BAG_TISSUE] = "Bag Tissue",
		[CustomConsumables.JOKER_Q] = "Joker?",
		[CustomConsumables.UNO_REVERSE_CARD] = "Reverse Card",
		[CustomConsumables.LOADED_DICE] = "Loaded Dice",
		[CustomConsumables.BEDSIDE_QUEEN] = "Bedside Queen",
		[CustomConsumables.QUEEN_OF_CLUBS] = "Queen of Clubs",
		[CustomConsumables.JACK_OF_CLUBS] = "Jack of Clubs",
		[CustomConsumables.JACK_OF_DIAMONDS] = "Jack of Diamonds",
		[CustomConsumables.JACK_OF_SPADES] = "Jack of Spades",
		[CustomConsumables.JACK_OF_HEARTS] = "Jack of Hearts",
		[CustomConsumables.QUASAR_SHARD] = "Quasar Shard",
		[CustomConsumables.BUSINESS_CARD] = "Business Card",
		[CustomConsumables.SACRIFICIAL_BLOOD] = "Sacrificial Blood",
		[CustomConsumables.LIBRARY_CARD] = "Library Card",
		[CustomConsumables.ANTIMATERIAL_CARD] = "Antimaterial Card",
		[CustomConsumables.FUNERAL_SERVICES] = "Funeral Services",
		[CustomConsumables.MOMS_ID] = "Mom's ID",
		[CustomConsumables.FIEND_FIRE] = "Fiend Fire",
		[CustomConsumables.DEMON_FORM] = "Demon Form"
	}
	
	-- DO NOT touch that! 
	-- Just fill in the Wiki and itemPools tables with the desired item's entry, and it will show up in the Encyclopedia
	for i = CustomCollectibles.ORDINARY_LIFE, CustomCollectibles.SIBLING_RIVALRY do
		Encyclopedia.AddItem({Class = "Repentance Plus", ID = i, WikiDesc = ItemsWiki[i], Pools = itemPools[i]})
		--Isaac.DebugString('Item ' .. tostring(i) .. 's entry succesfully loaded into the encyclopedia')
	end
	
	for i = CustomTrinkets.BASEMENT_KEY, CustomTrinkets.EMPTY_PAGE do
		Encyclopedia.AddTrinket({Class = "Repentance Plus", ID = i, WikiDesc = TrinketsWiki[i]})
	end
	
	for i = CustomPills.ESTROGEN, CustomPills.YUCK do
		Encyclopedia.AddPill({Class = "Repentance Plus", ID = i, WikiDesc = PillsWiki[i], Color = PillsColors[i]})
	end
	
	for i = CustomConsumables.RED_RUNE, CustomConsumables.JACK_OF_HEARTS do
		Encyclopedia.AddCard({Class = "Repentance Plus", ID = i, WikiDesc = CardsWiki[i], 
		Sprite = Encyclopedia.RegisterSprite("content/gfx/ui_cardfronts.anm2", tostring(spriteToCard[i]))})
	end
end

								----------------------
								--- SEWING MACHINE ---
								----------------------

if Sewn_API then
	-- Tank Boys
	Sewn_API:MakeFamiliarAvailable(CustomFamiliars.TOY_TANK_1, CustomCollectibles.TANK_BOYS)
	Sewn_API:AddFamiliarDescription(CustomFamiliars.TOY_TANK_1, 'The green Tank Boy gains homing ammunition', 'The red Tank Boy gains a laser side-gun')
	
	-- Bag-o-Trash
	Sewn_API:MakeFamiliarAvailable(CustomFamiliars.BAG_O_TRASH, CustomCollectibles.BAG_O_TRASH)
    --Sewn_API:AddFamiliarDescription(CustomFamiliars.BAG_O_TRASH, 'Bag-o-Trash will no longer have a chance to be destroyed on hit', 'Bag-o-Trash will spawn a blue spider for every blue fly it spawns')
	
	-- Cherubim
    Sewn_API:MakeFamiliarAvailable(CustomFamiliars.CHERUBIM, CustomCollectibles.CHERUBIM)
    Sewn_API:AddFamiliarDescription(CustomFamiliars.CHERUBIM, 'Cherubim gains increased God Head aura size and tear damage', 'Cherubim gains Pop! tears')
end


								----------------
								--- MINIMAPI ---
								----------------
if MinimapAPI then
	--MinimapAPI:AddPickup(id, Icon, EntityType, number variant, number subtype, function, icongroup, number priority)
	--MinimapAPI:AddIcon(id, Sprite, string animationName, number frame, (optional) Color color)
	
	local Icons = Sprite()
	Icons:Load("gfx/ui/ui_minimapi_icons_rplus.anm2", true)
	
	-- stargazer beggar
	MinimapAPI:AddIcon("stargazerslot", Icons, "stargazerslot", 0)
	MinimapAPI:AddPickup("stargazerslot", "stargazerslot", 6, 335, -1, MinimapAPI.PickupSlotMachineNotBroken, "slots", 0)
	
	-- chests
	MinimapAPI:AddIcon("scarletchest", Icons, "scarletchest", 0)
	MinimapAPI:AddPickup("scarletchest", "scarletchest", 5, 512, -1, MinimapAPI.PickupNotCollected, "chests", 7550)
	
	MinimapAPI:AddIcon("fleshchest", Icons, "fleshchest", 0)
	MinimapAPI:AddPickup("fleshchest", "fleshchest", 5, 513, -1, MinimapAPI.PickupNotCollected, "chests", 7050)
	
	MinimapAPI:AddIcon("blackchest", Icons, "blackchest", 0)
	MinimapAPI:AddPickup("blackchest", "blackchest", 5, 514, -1, MinimapAPI.PickupNotCollected, "chests", 7450)

	-- tainted hearts
	MinimapAPI:AddIcon("brokenheart", Icons, "brokenheart", 0)
	MinimapAPI:AddPickup("brokenheart", "brokenheart", 5, 10, 84, MinimapAPI.PickupNotCollected, "hearts", 10750)
	
	MinimapAPI:AddIcon("dauntlessheart", Icons, "dauntlessheart", 0)
	MinimapAPI:AddPickup("dauntlessheart", "dauntlessheart", 5, 10, 85, MinimapAPI.PickupNotCollected, "hearts", 10750)
	
	MinimapAPI:AddIcon("hoardedheart", Icons, "hoardedheart", 0)
	MinimapAPI:AddPickup("hoardedheart", "hoardedheart", 5, 10, 86, MinimapAPI.PickupNotCollected, "hearts", 10250)
	
	MinimapAPI:AddIcon("soiledheart", Icons, "soiledheart", 0)
	MinimapAPI:AddPickup("soiledheart", "soiledheart", 5, 10, 88, MinimapAPI.PickupNotCollected, "hearts", 10350)
	
	MinimapAPI:AddIcon("benightedheart", Icons, "benightedheart", 0)
	MinimapAPI:AddPickup("benightedheart", "benightedheart", 5, 10, 91, MinimapAPI.PickupNotCollected, "hearts", 10650)
	
	MinimapAPI:AddIcon("enigmaheart", Icons, "enigmaheart", 0)
	MinimapAPI:AddPickup("enigmaheart", "enigmaheart", 5, 10, 92, MinimapAPI.PickupNotCollected, "hearts", 10750)
	
	MinimapAPI:AddIcon("capriciousheart", Icons, "capriciousheart", 0)
	MinimapAPI:AddPickup("capriciousheart", "capriciousheart", 5, 10, 93, MinimapAPI.PickupNotCollected, "hearts", 10750)
	
	MinimapAPI:AddIcon("fetteredheart", Icons, "fetteredheart", 0)
	MinimapAPI:AddPickup("fetteredheart", "fetteredheart", 5, 10, 98, MinimapAPI.PickupNotCollected, "hearts", 10550)
	
	MinimapAPI:AddIcon("zealotheart", Icons, "zealotheart", 0)
	MinimapAPI:AddPickup("zealotheart", "zealotheart", 5, 10, 99, MinimapAPI.PickupNotCollected, "hearts", 10650)
	
	MinimapAPI:AddIcon("desertedheart", Icons, "desertedheart", 0)
	MinimapAPI:AddPickup("desertedheart", "desertedheart", 5, 10, 100, MinimapAPI.PickupNotCollected, "hearts", 10450)	
end



								-- blacklisting some stuff ----------
								-- for Sodom & Gomorrah characters --

if XalumMods and XalumMods.SodomAndGomorrah then
	XalumMods.SodomAndGomorrah.AddBlacklistedSodomGomorrahItems({
		CustomCollectibles.CEILING_WITH_THE_STARS,
		CustomCollectibles.BIRD_OF_HOPE,
		CustomCollectibles.MARK_OF_CAIN,
		CustomCollectibles.STARGAZERS_HAT
	})
	
	XalumMods.SodomAndGomorrah.AddBlacklistedSodomGomorrahTrinkets({
		CustomTrinkets.KEY_TO_THE_HEART,
		CustomTrinkets.TRICK_PENNY,
		CustomTrinkets.ADAMS_RIB
	})
end


































