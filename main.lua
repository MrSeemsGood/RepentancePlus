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
local MOD_VERSION = "1.25a"
local sfx = SFXManager()
local music = MusicManager()
local RNGobj = RNG()
local json = require("json")
local HUDValueRenderOffset = Vector(20, 12)
local CustomData
local noCustomHearts

--[[ for displaying achievement papers
achievement = Sprite()
achievement:Load("gfx/ui/achievement/achievements.anm2", true)
--]]

-- effect helpers
local CripplingHandsHelper = Isaac.GetEntityVariantByName("Crippling Hands Helper")
local FallingKnifeHelper = Isaac.GetEntityVariantByName("Falling Knife Helper")
local AnimatedItemDummyEntity = Isaac.GetEntityVariantByName("AnimatedItemDummyEntity")
local PureSoul = Isaac.GetEntityVariantByName("Pure Soul")
local PlacardBorder = Isaac.GetEntityVariantByName("Handicapped Placard Effect Border")

-- helpers for rendering
local hideErrorMessage
local ErrorMessage = "Warning! Custom Mod Data of Repentance Plus #wasn't loaded, the mod could work incorrectly. #Custom Mod Data will be properly loaded next time you start a new run. #(Type 'hide' into the console or press H to hide this message)"

local PenIcon = Sprite()
PenIcon:Load("gfx/ui/ui_visual_clues.anm2", true)
PenIcon:Play("PenReady", false)
PenIcon.PlaybackSpeed = 0.5

local CoinHeartSprite = Sprite()
CoinHeartSprite:Load("gfx/ui/ui_coinhearts.anm2", true)
local HeartRenderPos = Vector(122, 11)

local SoulIcon = Sprite()
SoulIcon:Load("gfx/ui/ui_visual_clues.anm2", true)
SoulIcon:Play("SoulReady", false)
SoulIcon.PlaybackSpeed = 0.5

local RedMapIcon = Sprite()
RedMapIcon:Load("gfx/ui/ui_visual_clues.anm2", true)
local MapRenderPos = Vector(20, 200)

local DNAPillIcon = Sprite()
DNAPillIcon:Load("gfx/ui/ui_dnapillhelper.anm2", true)
DNAPillIcon.Scale = Vector(0.5, 0.5)

local LineOfSightEyes = Sprite()
LineOfSightEyes:Load("gfx/ui/ui_lineofsight_eyes.anm2", true)

local LeviathanGiantBookAnim = Sprite()	-- used not only for Book of Leviathan, but for imitating Berkano rune pop up
local animLength
local fakeBerkanoCall
-------------
-- chances	
local BASEMENTKEY_CHANCE = 15			-- chance to replace golden chest with an old chest
local HEARTKEY_CHANCE = 5				-- chance for enemy to drop Flesh chest on death
local SUPERBERSERK_ENTER_CHANCE = 25	-- chance to enter berserk state via Temper Tantrum
local SUPERBERSERK_DELETE_CHANCE = 5	-- chance to erase enemies while in this state
local TRASHBAG_BREAK_CHANCE = 1			-- chance of Bag-o-Trash breaking
local CHERRY_SPAWN_CHANCE = 20			-- chance to spawn cherry on enemy death
local SLEIGHTOFHAND_UPGRADE_CHANCE = 20	-- chance to upgrade your coins via Sleight of Hand
local JACK_CHANCE = 60					-- chance for Jack cards to spawn their respective type of pickup
local TRICKPENNY_CHANCE = 20			-- chance to save your consumable when using it via Trick Penny
local CEREM_DAGGER_LAUNCH_CHANCE = 7 	-- chance to launch a dagger
local NIGHT_SOIL_CHANCE = 75 			-- chance to negate curse
local NERVEPINCH_USE_CHANCE = 80		-- chance to activate your active item for free via Nerve Pinch
local FLESHCHEST_REPLACE_CHANCE = 25	-- chance for Flesh chests to replace mimic, spiked normally
local FLESHCHEST_OPEN_CHANCE = 33		-- chance to open Flesh chest 
local SCARLETCHEST_REPLACE_CHANCE = 10	-- chance for Scarlet chests to spawn
local STARGAZER_PAYOUT_CHANCE = 20		-- chance for Stargazer beggar to payout with an item
local BLOODYROCKS_REPLACE_CHANCE = 10	-- chance for Bloody (Ultra secret, Tainted) rocks to replace spiked rocks
local CRIPPLE_TEAR_CHANCE = 2			-- chance to cripple enemies by hitting them with your tears
local DARK_ARTS_CHANCE = 8				-- chance to activate Dark Arts if hit while having Key Knife trinket
local SOUL_BOND_HEARTDROP_CHANCE = 33	-- chance for chained enemy to drop a doul heart on death
local JEWEL_DROP_CHANCE = 7.5 			-- base chance for sins to drop Jewel on death

-- cooldowns
local ENRAGED_SOUL_COOLDOWN = 7 * 60			-- Enraged Soul familiar
local REDBOMBER_LAUNCH_COOLDOWN = 1 * 60 		-- throwing red bombs
local MAGICPEN_CREEP_COOLDOWN = 4 * 60 			-- Magic Pen creep
local NERVEPINCH_HOLD = 60 * 8					-- Nerve Pinch
local SIBLING_STATE_SWITCH_COOLDOWN = 15 * 30	-- switching Sibling forms
local DOGMA_ATTACK_COOLDOWN = 60 * 6			-- Dogma-ish attack

									-----------------
									----- ENUMS -----
									-----------------

Costumes = {
	-- add ONLY NON-PERSISTENT COSTUMES here, because persistent costumes work without lua
	BIRD_OF_HOPE = Isaac.GetCostumeIdByPath("gfx/characters/costume_004_birdofhope.anm2")
}

CustomTearVariants = {
	CEREMONIAL_BLADE = Isaac.GetEntityVariantByName("Ceremonial Dagger Tear"),
	SINNERS_HEART = Isaac.GetEntityVariantByName("Sinner's Heart Tear"),
	CORN = Isaac.GetEntityVariantByName("Corn Tear"),
	ANTIMATERIAL_CARD = Isaac.GetEntityVariantByName("Antimaterial Card Tear"),
	REJECTED_BABY = Isaac.GetEntityVariantByName("Rejected Baby Tear"),
	DOGMA_FEATHER = Isaac.GetEntityVariantByName("Dogma Feather Tear"),
	VALENTINES_CARD = Isaac.GetEntityVariantByName("Valentine's Card Tear")
}

CustomFamiliars = {
	BAG_O_TRASH = Isaac.GetEntityVariantByName("Bag-o-Trash"),
	CHERUBIM = Isaac.GetEntityVariantByName("Cherubim"),
	CHERRY = Isaac.GetEntityVariantByName("Cherry"),
	BIRD = Isaac.GetEntityVariantByName("Bird of Hope"),
	ENRAGED_SOUL = Isaac.GetEntityVariantByName("Enraged Soul"),
	TOY_TANK_1 = Isaac.GetEntityVariantByName("Toy Tank 1"),
	TOY_TANK_2 = Isaac.GetEntityVariantByName("Toy Tank 2"),
	SIBLING_1 = Isaac.GetEntityVariantByName("Peaceful Sibling 1"),
	SIBLING_2 = Isaac.GetEntityVariantByName("Peaceful Sibling 2"),
	FIGHTING_SIBLINGS = Isaac.GetEntityVariantByName("Fighting Siblings"),
	REJECTION_FETUS = Isaac.GetEntityVariantByName("Rejection Fetus"),
	ENOCH = Isaac.GetEntityVariantByName("Enoch"),
	ENOCH_B = Isaac.GetEntityVariantByName("Enoch (tainted)"),
	SPIRITUAL_RESERVES_SUN = Isaac.GetEntityVariantByName("Spiritual Reserves (Sun)"),
	SPIRITUAL_RESERVES_MOON = Isaac.GetEntityVariantByName("Spiritual Reserves (Moon)"),
	FRIENDLY_SACK = Isaac.GetEntityVariantByName("Friendly Sack"),
	ULTRA_FLESH_KID_L1 = Isaac.GetEntityVariantByName("Ultra Flesh Kid lvl 1"),
	ULTRA_FLESH_KID_L2 = Isaac.GetEntityVariantByName("Ultra Flesh Kid lvl 2"),
	ULTRA_FLESH_KID_L3 = Isaac.GetEntityVariantByName("Ultra Flesh Kid lvl 3"),
	ULTRA_FLESH_KID_L3_HEAD = Isaac.GetEntityVariantByName("Ultra Flesh Kid lvl 3 (head)"),
	HANDICAPPED_PLACARD = Isaac.GetEntityVariantByName("Handicapped Placard")
}

CustomCollectibles = {
	ORDINARY_LIFE = Isaac.GetItemIdByName("Ordinary Life"),
	COOKIE_CUTTER = Isaac.GetItemIdByName("Cookie Cutter"),
	RUBIKS_CUBE = Isaac.GetItemIdByName("Rubik's Cube"),
	MAGIC_CUBE = Isaac.GetItemIdByName("Magic Cube"),
	MAGIC_PEN = Isaac.GetItemIdByName("Magic Pen"),					
	SINNERS_HEART = Isaac.GetItemIdByName("Sinner's Heart"),
	MARK_OF_CAIN = Isaac.GetItemIdByName("The Mark of Cain"),			
	BAG_O_TRASH = Isaac.GetItemIdByName("Bag o Trash"),
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
	HAND_ME_DOWNS = Isaac.GetItemIdByName("Hand-Me-Downs"),
	VAULT_OF_HAVOC = Isaac.GetItemIdByName("Vault of Havoc"),
	FRIENDLY_SACK = Isaac.GetItemIdByName("Friendly Sack"),
	ULTRA_FLESH_KID = Isaac.GetItemIdByName("Ultra Flesh Kid!"),
	BOOK_OF_LEVIATHAN = Isaac.GetItemIdByName("Book of Leviathan"),
	MAGIC_MARKER = Isaac.GetItemIdByName("Magic Marker"),
	PURE_SOUL = Isaac.GetItemIdByName("Pure Soul"),
	BOOK_OF_JUDGES = Isaac.GetItemIdByName("Book of Judges"),
	HANDICAPPED_PLACARD = Isaac.GetItemIdByName("Handicapped Placard")
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
	KEY_KNIFE = Isaac.GetTrinketIdByName("Key Knife"),
	SHATTERED_STONE = Isaac.GetTrinketIdByName("Shattered Stone")
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
	VALENTINES_CARD = Isaac.GetCardIdByName("Valentine's Card"),
	SPIRITUAL_RESERVES = Isaac.GetCardIdByName("Spiritual Reserves"),
	MIRRORED_LANDSCAPE = Isaac.GetCardIdByName("Mirrored Landscape"),
	CURSED_CARD = Isaac.GetCardIdByName("Cursed Card"),
	-- SIN'S JEWELS
	CANINE_OF_WRATH = Isaac.GetCardIdByName("Canine of Wrath"),
	CROWN_OF_GREED = Isaac.GetCardIdByName("Crown of Greed"),
	FLOWER_OF_LUST = Isaac.GetCardIdByName("Flower of Lust"),
	ACID_OF_SLOTH = Isaac.GetCardIdByName("Acid of Sloth"),
	MASK_OF_ENVY = Isaac.GetCardIdByName("Mask of Envy"),
	APPLE_OF_PRIDE = Isaac.GetCardIdByName("Apple of Pride"),
	VOID_OF_GLUTTONY = Isaac.GetCardIdByName("Void of Gluttony")
}

CustomPickups = {
	FLESH_CHEST = Isaac.GetEntityVariantByName("Flesh Chest"),
	SCARLET_CHEST = Isaac.GetEntityVariantByName("Scarlet Chest"),
	BLACK_CHEST = Isaac.GetEntityVariantByName("Black Chest"),
	COFFIN = Isaac.GetEntityVariantByName("Coffin"),
	-- tainted hearts
	TaintedHearts = {
		HEART_BROKEN  = 84,
		HEART_DAUNTLESS = 85,
		HEART_HOARDED  = 86,
		HEART_SOILED = 88,
		HEART_CURDLED = 89,
		HEART_SAVAGE = 90,
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
		["Isaac"] = {Unlocked = false, Type = 5, Variant = nil, SubType = CustomCollectibles.RUBIKS_CUBE}, 
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
	COFFIN = {
		CollectibleType.COLLECTIBLE_DRY_BABY,
		CollectibleType.COLLECTIBLE_DOG_TOOTH,
		CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE,
		CollectibleType.COLLECTIBLE_MARROW,
		CollectibleType.COLLECTIBLE_SLIPPED_RIB,
		CollectibleType.COLLECTIBLE_POINTY_RIB,
		CollectibleType.COLLECTIBLE_JAW_BONE,
		CollectibleType.COLLECTIBLE_BRITTLE_BONES,
		CollectibleType.COLLECTIBLE_BONE_SPURS
	}
}

DropTables = {
	BLACK_CHEST = {
		{40, {{PickupVariant.PICKUP_GRAB_BAG, 2}}},
		{65, {{PickupVariant.PICKUP_TAROTCARD, 0}}},
		{85, {{PickupVariant.PICKUP_GRAB_BAG, 2}, {300, CustomConsumables.SPINDOWN_DICE_SHARD}}},
		{100, {{PickupVariant.PICKUP_GRAB_BAG, 2}, {300, Card.RUNE_BLACK}}}
	},
	BLOODYROCKS = {
		{15, {{300, Card.CARD_CRACKED_KEY}, {300, CustomConsumables.RED_RUNE}}},
		{40, {{300, CustomConsumables.RED_RUNE}, {10, HeartSubType.HEART_FULL}}},
		{50, {{10, HeartSubType.HEART_FULL}, {10, HeartSubType.HEART_FULL}}},
		{55, {{CustomPickups.SCARLET_CHEST, 0}}},
		{100, {{10, HeartSubType.HEART_FULL}, {300, Card.CARD_CRACKED_KEY}}},
	}
}

CustomStatups = {
	Damage = {
		SINNERS_HEART_ADD = 2,
		SINNERS_HEART_MUL = 1.5,
		MAGIC_SWORD_MUL = 2,
		CHEESE_GRATER = 0.5,
		BLESS_OF_THE_DEAD = 0.75,
		PILL_YUM = 0.05,
		BONE_MEAL_MUL = 1.1,
		MOTHERS_LOVE = 0.2,
		DEMON_FORM = 0.2,
		APPLE_OF_PRIDE_MUL = 1.25,
		--
		DMG_TEMPORARY = 1.25
	},
	Luck = {
		LOADED_DICE = 10,
		PILL_YUM = 0.07,
		MOTHERS_LOVE = 0.2,
		APPLE_OF_PRIDE = 2
	},
	Tears = {
		ORDINARY_LIFE_MUL = 0.8,
		GUSTY_BLOOD = 0.16,
		PILL_YUM = 0.04,
		MOTHERS_LOVE = 0.1,
		CURSED_CARD = 0.17,
		APPLE_OF_PRIDE_MUL = 0.85,
		MASK_OF_ENVY = 0.45
	},
	Speed = {
		GUSTY_BLOOD = 0.07,
		MOTHERS_LOVE = 0.05,
		NERVE_PINCH = -0.03,
		HAND_ME_DOWNS = 0.2,
		APPLE_OF_PRIDE = 0.3
	},
	Range = {
		SINNERS_HEART = 2,
		PILL_YUM = 0.07,
		MOTHERS_LOVE = 0.25,
		APPLE_OF_PRIDE = 1.5	
	},
	ShotSpeed = {
		SINNERS_HEART = -0.2,
		ANGELS_WINGS = 0.3
	},
}

-- used by Bag Tissue, Shattered Stone and Flower of Lust
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
		[CustomPickups.TaintedHearts.HEART_EMPTY] = 7,
		[CustomPickups.TaintedHearts.HEART_FETTERED] = 5,
		[CustomPickups.TaintedHearts.HEART_ZEALOT] = 7,
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

DIRECTION_FLOAT_ANIM = {
	[Direction.NO_DIRECTION] = "FloatDown", 
	[Direction.LEFT] = "FloatLeft",
	[Direction.UP] = "FloatUp",
	[Direction.RIGHT] = "FloatRight",
	[Direction.DOWN] = "FloatDown"
}

DIRECTION_SHOOT_ANIM = {
	[Direction.NO_DIRECTION] = "FloatShootDown",
	[Direction.LEFT] = "FloatShootLeft",
	[Direction.UP] = "FloatShootUp",
	[Direction.RIGHT] = "FloatShootRight",
	[Direction.DOWN] = "FloatShootDown"
}

DIRECTION_VECTOR = {
	[Direction.NO_DIRECTION] = Vector(0, 1),	-- when you don't shoot or move, you default to HeadDown
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}	

VECTOR_CARDINAL = {
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

-- VERY COOL AND USEFUL HELPERS TO MANAGE UNLOCKABLE ITEMS (THEY ALL WORK NOW!) --
local function IsCollectibleUnlocked(colType)
	return game:GetItemPool():RemoveCollectible(colType)
end

local function GetUnlockedVanillaCollectible(allPools, includeActives, excludeTags)
	allPools = allPools or false
	includeActives = includeActives or false
	excludeTags = excludeTags or ItemConfig.TAG_QUEST
    local itemPool = game:GetItemPool()
    
	repeat
		if allPools then 
			RNGobj:SetSeed(Random() + 1, 1)
			local randomPool = RNGobj:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
			colResult = itemPool:GetCollectible(randomPool, true)
		else
			local rt = game:GetRoom():GetType()
			local ip		-- item pool
			
			if rt == 2 or rt == 22 then ip = 1
			elseif rt == 5 then ip = 2
			elseif rt == 7 or rt == 8 then ip = 5
			elseif rt == 10 then ip = 12
			elseif rt == 14 then ip = 3
			elseif rt == 15 then ip = 4
			elseif rt == 24 then ip = 26
			elseif rt == 29 then ip = 24
			else ip = 0
			end
			
			colResult = itemPool:GetCollectible(ip, true)
		end
	until Isaac.GetItemConfig():GetCollectible(colResult).Tags & excludeTags ~= excludeTags	-- tags
	and (includeActives or Isaac.GetItemConfig():GetCollectible(colResult).Type % 3 == 1) 		-- passive or familiar (type 1 or 4)
	
	return colResult
end

local function GetUnlockedCollectibleFromCustomPool(poolTableEntry)
	local freezePreventChecker = 0
	RNGobj:SetSeed(Random() + 1, 1)
	
	repeat
		local roll = RNGobj:RandomInt(#poolTableEntry) + 1
		colResult = poolTableEntry[roll]
		freezePreventChecker = freezePreventChecker + 1
	until IsCollectibleUnlocked(colResult) or freezePreventChecker == 1000
	
	if freezePreventChecker == 1000 then
		sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 2, false, 1, 0)
		print("WARNING: this item pool is exhausted, it will not spawn any more items!")
		return 25	-- good ol breakfast
	else
		return colResult
	end
end

local function GetUnlockedTrinketFromCustomPool(poolTableEntry)
	local freezePreventChecker = 0
	RNGobj:SetSeed(Random() + 1, 1)
	
	repeat
		local roll = RNGobj:RandomInt(#poolTableEntry) + 1
		trinketRes = poolTableEntry[roll]
		freezePreventChecker = freezePreventChecker + 1
	until game:GetItemPool():RemoveTrinket(trinketRes) or freezePreventChecker == 1000
	
	if freezePreventChecker == 1000 then
		print("WARNING: this trinket pool is exhausted, it will not spawn any more trinkets!")
		return nil
	else
		return trinketRes
	end
end

function blacklistCollectibles(player, collectible1, collectible2)
	-- `player` (EntityPlayer): a player
	-- `collectible1` (int): what collectible should be blacklisted
	-- `collectible2` (int/table): what collectible(s) should collectible1 be blacklisted from
	if game:GetFrameCount() % 30 ~= 0 then return end
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
----------------------------------------------------------------------------------

-- Handle displaying error message advising players to restart
local function DisplayErrorMessage()
	if not hideErrorMessage then
		local newLineOffset = 0
		for line in string.gmatch(ErrorMessage, '([^#]+)') do 
			Isaac.RenderText(line, 30, 220 + newLineOffset, 1, 0.2, 0.2, 1) 
			newLineOffset = newLineOffset + 12
		end
	end
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

local function getMothersLoveStatBoost(fVariant, insertCustom, boostMul)
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

local function getTrueFamiliarNum(player, collectible)
	return player:GetCollectibleNum(collectible) + player:GetEffects():GetCollectibleEffectNum(collectible)
end

local function canOpenScarletChests(player)
	return ((player:GetActiveItem(0) == CollectibleType.COLLECTIBLE_RED_KEY and player:GetActiveCharge(0) >= 4)
	or player:HasTrinket(TrinketType.TRINKET_CRYSTAL_KEY) or player:GetCard(0) == Card.CARD_CRACKED_KEY
	or player:GetCard(0) == Card.CARD_SOUL_CAIN)
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
	
	if DieRoll < 0.8  then
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

local function makeRoomAngelShop(room)
	for i = 1, room:GetGridSize() do
		if room:GetGridEntity(i)
		and room:GetGridEntity(i):GetType() ~= GridEntityType.GRID_DOOR and room:GetGridEntity(i):GetType() ~= GridEntityType.GRID_WALL then
			room:RemoveGridEntity(i, 0, false)
		end
	end
	
	if room:GetRoomShape() == RoomShape.ROOMSHAPE_1x1 then
		AngelPos = Vector(320, 200)
	elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IH then
		AngelPos = Vector(320, 240)
	elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IV then
		AngelPos = Vector(320, 200)
	end
	
	Isaac.GridSpawn(GridEntityType.GRID_STATUE, 1, AngelPos, false)			
	game:ShowHallucination(0, BackdropType.CATHEDRAL)
	if sfx:IsPlaying(33) then sfx:Stop(33) end
end

local function isInPlayersLineOfSight(EntityNPC, player)
	return math.abs(DIRECTION_VECTOR[player:GetHeadDirection()]:GetAngleDegrees() - (EntityNPC.Position - player.Position):GetAngleDegrees()) < 37.5
end

local function isItemPocketSlotBlacklisted(i)
	return i == CollectibleType.COLLECTIBLE_GLASS_CANNON
	or i == CollectibleType.COLLECTIBLE_BROKEN_GLASS_CANNON
	or i == CollectibleType.COLLECTIBLE_D_INFINITY
	or i == CollectibleType.COLLECTIBLE_ERASER
	or i == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS
	or i == CollectibleType.COLLECTIBLE_TELEKINESIS
	or i == CollectibleType.COLLECTIBLE_SPIN_TO_WIN
	or i == CollectibleType.COLLECTIBLE_DECAP_ATTACK
	or i == CollectibleType.COLLECTIBLE_PLACEBO
	or i == CollectibleType.COLLECTIBLE_BLANK_CARD
	or i == CollectibleType.COLLECTIBLE_CLEAR_RUNE
	or i == CustomCollectibles.STARGAZERS_HAT
	or i == CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD
	or i == CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP
end

local function crippleEnemy(enemy)
	local d = enemy:GetData()
	if not d.IsCrippled and enemy:IsVulnerableEnemy() 
	and enemy:IsActiveEnemy(false) and not enemy:IsBoss() then
		-- applying custom debuffs to enemies
		d.IsCrippled = true
		d.CrippleStartFrame = game:GetFrameCount()
		d.CrippleDeathBurst = false
		local crippleHands = Isaac.Spawn(1000, CripplingHandsHelper, 0, enemy.Position + Vector(0, 5), Vector.Zero, enemy):ToEffect()
		crippleHands:GetSprite():Play("ClawsAppearing")
		
		return true
	end
	
	return false
end

local function addTemporaryDmgBoost(player)
	local data = player:GetData()
	local flag = data.flagGiveTempBoost
	local step = data.boostTimeStep
	local num = data.numTempBoosts
	
	if not flag then flag = true end
	if not step then step = 0 end
	if not num then num = 1 else num = num + 1 end
	
	player:GetData().flagGiveTempBoost = flag
	player:GetData().boostTimeStep = step
	player:GetData().numTempBoosts = num
end

local function getRedHeartPickups()
	local t = {}
	
	for _, heart in pairs(Isaac.FindByType(5, 10, -1)) do
		if (heart.SubType == 1 or heart.SubType == 2 or heart.SubType == HeartSubType.HEART_DOUBLEPACK
		or heart.SubType == HeartSubType.HEART_SCARED or heart.SubType == CustomPickups.TaintedHearts.HEART_HOARDED)
		and heart:ToPickup().Price == 0 then
			table.insert(t, heart)
		end
	end

	return t
end

local function isRoomFightInProgress(room)
	local t = room:GetType()
	
	if t == RoomType.ROOM_CHALLENGE or t == RoomType.ROOM_BOSSRUSH then
		return room:IsAmbushActive()
	else
		return not room:IsClear()
	end
end

-- for Quasar and Quasar Shard
------------------------------
local function isOptionsPickupIndexNew(t, index)
	-- `t`: {{}, {}, {}} - table of tables
	for _, subtable in pairs(t) do
		if subtable[2] == index then
			return false
		end
	end
	
	return true
end

local function bitmaskIntoNumber(n)
	-- turns black hearts bitmask into the amount of black hearts player has
	local y = {}
	local val = 0
	while n > 0 do
		table.insert(y, n % 2)
		n = n // 2
	end
	for _, elem in pairs(y) do
		if elem == 1 then val = val + 1 end
	end
	
	return val
end

local function properQuasarUse(player)
	local roomCollectibleInfo = {}
	
	for _, c in pairs(Isaac.FindByType(5, 100, -1)) do
		if c:ToPickup().Price == 0 then
			if c.SubType > 0 and isOptionsPickupIndexNew(roomCollectibleInfo, c:ToPickup().OptionsPickupIndex) then
				table.insert(roomCollectibleInfo, {c.SubType, c:ToPickup().OptionsPickupIndex})
			end
			Isaac.Spawn(1000, EffectVariant.POOF01, 0, c.Position, Vector.Zero, player)
			c:Remove()
		end
	end
	
	if player.QueuedItem and player.QueuedItem.Item 
	and player.QueuedItem.Item:IsCollectible() then
		-- `Item` becomes inaccessible after we flush the item queue so I'd like to save the info
		local id = player.QueuedItem.Item.ID
		-- oh boy how great is that to work with queued items. so much fun!
		local b = player.QueuedItem.Item.AddBombs
		local b_p = player:GetNumBombs()
		local c = player.QueuedItem.Item.AddCoins
		local c_p = player:GetNumCoins()
		local k = player.QueuedItem.Item.AddKeys
		local k_p = player:GetNumKeys()
		local mh = player.QueuedItem.Item.AddMaxHearts
		local mh_p = player:GetMaxHearts()
		local h = player.QueuedItem.Item.AddHearts
		local h_p = player:GetHearts()
		local sh = player.QueuedItem.Item.AddSoulHearts
		local sh_p = player:GetSoulHearts()
		local bh = player.QueuedItem.Item.AddBlackHearts
		local bh_p = bitmaskIntoNumber(player:GetBlackHearts())
		--
		player:FlushQueueItem()
		player:RemoveCollectible(id)
		--
		player:AddBombs(-math.min(b, 99 - b_p))
		player:AddCoins(-math.min(c, 99 - c_p))
		player:AddKeys(-math.min(k, 99 - k_p))
		player:AddMaxHearts(-math.min(mh, 24 - mh_p))
		player:AddHearts(-math.min(h, player:GetEffectiveMaxHearts() - h_p))
		player:AddSoulHearts(-math.min(sh, 24 - sh_p))
		player:AddBlackHearts(-math.min(bh, 24 - bh_p))
		
		for _, pickup in pairs(Isaac.FindByType(5)) do
			if pickup.FrameCount == 0 and pickup.Position:Distance(player.Position) < 250 then
				pickup:Remove()
			end
		end
		
		table.insert(roomCollectibleInfo, {id, 0})
	end
	
	for i = 1, #roomCollectibleInfo * 3 do
		newID = GetUnlockedVanillaCollectible(false, false)
		player:AddItemWisp(newID, player.Position, true)
	end
	sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1, 2, false, 1, 0)
end
-------------------------

-- function stolen by me from Bogdan Ryduka, who stole it from kil
-- that's how mafia works everybody
function GetScreenCenterPosition()
	local room = game:GetRoom()
	local shape = room:GetRoomShape()
	local centerOffset = (room:GetCenterPos()) - room:GetTopLeftPos()
	local pos = room:GetCenterPos()
	
	if centerOffset.X > 260 then
		pos.X = pos.X - 260
	end
	if shape == RoomShape.ROOMSHAPE_LBL or shape == RoomShape.ROOMSHAPE_LTL then
		pos.X = pos.X - 260
	end
	
	if centerOffset.Y > 140 then
		pos.Y = pos.Y - 140
	end
	if shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LTL then
		pos.Y = pos.Y - 140
	end
	
	return Isaac.WorldToRenderPosition(pos, false)
end

local function getRightMostHeartForRender(player)
	-- I miserably failed in rendering hearts in separate containers, so they can be stacked on top of each other for now
	local rm 
	
	if player:GetSoulHearts() > 0 then 
		rm = math.floor((player:GetMaxHearts() + player:GetSoulHearts()) / 2  + player:GetBoneHearts() + 0.5)
	elseif player:GetBoneHearts() > 0 then 
		rm = player:GetBoneHearts() + player:GetMaxHearts() / 2
	else 
		rm = math.floor(player:GetHearts()/2 + 0.5)
	end
	
	return rm
end

local function HeartRender(player, heartData, heartAnim)
	--[[
		`player` (EntityPlayer): player whose Tainted hearts need to be rendered. CURRENTLY ONLY SUPPORTS MAIN PLAYER (index 0) !!!
		`heartData` (int): CustomData entry that refers to the number of certain Tainted hearts that the player owns
		`heartAnim` (string): animation that refers to a certain Tainted heart
	]]
	
	if not CustomData or heartData == 0 then return end
	if game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == LevelCurse.CURSE_OF_THE_UNKNOWN then return end
	local TopVector
	local HeartRenderOffset = Options.HUDOffset * Vector(20, 12)
	
	if heartData > 0 then
		local heartSprite = Sprite()
		heartSprite:Load("gfx/ui/ui_taintedhearts.anm2", true)
		heartSprite:Play(heartAnim, true)
		if heartAnim == "Dauntless" then 
			heartbegin = getRightMostHeartForRender(player) + 1 - heartData - player:GetGoldenHearts() 
			heartend = getRightMostHeartForRender(player) - player:GetGoldenHearts()
		elseif heartAnim == "Soiled" then 
			heartbegin = getRightMostHeartForRender(player) + 1 - heartData - player:GetGoldenHearts() - CustomData.TaintedHearts.DAUNTLESS.Num 
			heartend = getRightMostHeartForRender(player) - player:GetGoldenHearts() - CustomData.TaintedHearts.DAUNTLESS.Num 
		elseif heartAnim == "Zealot" then 
			heartbegin = getRightMostHeartForRender(player) + 1 - heartData - player:GetGoldenHearts() - CustomData.TaintedHearts.DAUNTLESS.Num - CustomData.TaintedHearts.SOILED
			heartend = getRightMostHeartForRender(player) - player:GetGoldenHearts() - CustomData.TaintedHearts.DAUNTLESS.Num - CustomData.TaintedHearts.SOILED
		else
			heartbegin = getRightMostHeartForRender(player) + 1 - heartData 
			heartend = getRightMostHeartForRender(player)
		end
		
		for i = heartbegin, heartend do
			if (i < 7) then
				TopVector = Vector((i - 1) * 12 + 48, 12)
			elseif (i < 13) then
				TopVector = Vector((i - 7) * 12 + 48, 22)
			else
				TopVector = Vector((i - 13) * 12 + 48, 32)
			end
			heartSprite:Render(TopVector + Vector.One + HeartRenderOffset, Vector.Zero, Vector.Zero)
			heartSprite:Update()
		end
	end
end

-- for animated Angel's Wings pedestal
local function hasEffectOnIt(ent)
	for _, eff in pairs(Isaac.FindByType(1000, AnimatedItemDummyEntity, 0, true, true)) do
		if eff.SpawnerEntity and GetPtrHash(eff.SpawnerEntity) == GetPtrHash(ent) then return true end
	end
	
	return false
end



						-----------------------------
						-- CALLBACK TIED FUNCTIONS --
						-----------------------------

-- very epic and cool command to prevent game crash when reloading this mod through the mod menu
rplus:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)


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
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
	end
	
	-- deleting certain trinkets from rotation
	game:GetItemPool():RemoveTrinket(CustomTrinkets.WAIT_NO)

	if not Continued then
		hideErrorMessage = false
		noCustomHearts = false
		
		CustomData = {
			Items = {
				BIRD_OF_HOPE = {NumRevivals = 0, BirdCaught = true},
				RUBIKS_CUBE = {Counter = 0},
				MARK_OF_CAIN = nil,
				BAG_O_TRASH = {Levels = 0},
				BLACK_DOLL = {ABSepNumber = 0, EntitiesGroupA = {}, EntitiesGroupB = {}},
				TEMPER_TANTRUM = {SuperBerserkState = false},
				ENRAGED_SOUL = {SoulLaunchCooldown = nil, AttachedEnemy = nil},
				CEILING_WITH_THE_STARS = {SleptInBed = false},
				TWO_PLUS_ONE = {ItemsBought_COINS = 0, ItemsBought_HEARTS = 0},
				CHEESE_GRATER = {NumUses = 0},
				BLESS_OF_THE_DEAD = {NumUses = 0},
				RED_MAP = {ShownOnFloorOne = false},
				GUSTY_BLOOD = {CurrentTears = 0, CurrentSpeed = 0},
				RED_BOMBER = {BombLaunchCooldown = 0},
				MAGIC_PEN = {CreepSpewCooldown = nil},
				BOOK_OF_GENESIS = {Index = 5},
				MOTHERS_LOVE = {NumStats = 0, NumFriends = 0},
				BLOODVESSEL = {DamageFlag = false},
				NERVE_PINCH = {Hold = 300, NumTriggers = 0},
				RED_KING = {redCrawlspacesData = {}},
				BOTTOMLESS_BAG = {UseFrame = 0, TearCount = 0, Data = false},
				ANGELS_WINGS = {AttackCooldown = nil, NextAttack = 1},
				MAGIC_MARKER = {CardDrop = false},
				VAULT_OF_HAVOC = {EnemyList = {}, Data = false, SumHP = 0, EnemiesSpawned = false},
				PURE_SOUL = {isPortalSuperSecret = false},
				BOOK_OF_JUDGES = {BeamTargets = {}, NoBeams = false}
			},
			Cards = {
				JACK = nil,
				DEMON_FORM = {NumUses = 0},
				Jewels = {
					GREED = {NumUses = 0}
				}
			},
			Trinkets = {
				GREEDS_HEART = "CoinHeartEmpty",
				BONE_MEAL = {Levels = 0},
				ANGELS_CROWN = {treasureRoomsData = {{index = -1, needToConvert = false},
												     {index = -1, needToConvert = false}}}
			},
			Pills = {
				LAXATIVE = {UseFrame = nil},
				YUCK = {UseFrame = -900},
				YUM = {NumLuck = 0, NumDamage = 0, NumRange = 0, NumTears = 0, UseFrame = -900},
				PHANTOM_PAINS = {UseFrame = -900}
			},
			NumTaintedRocks = 0,
			FleshChestConsumedHP = 0,
			ErasedEnemies = {},
			TaintedHearts = {
				HEARTFLAG_NO_HOARDED_REROLL = false,
				ZEALOT = 0,
				EMPTY = 0,
				SOILED = 0,
				DAUNTLESS = {
					Num = 0,
					Data = true
				}
			}
		}
		
		if CustomData then 
			print("Repentance Plus mod v" .. MOD_VERSION .. " initialized")
			print("To prevent tainted hearts from spawning, type `customhearts_none`")
		end
		
		--[[ Spawn items/trinkets or turn on debug commands for testing here if necessary
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


						-- MC_POST_GAME_END --										
						----------------------
function rplus:GameEnded(isGameOver)
	local maxID = Isaac.GetItemConfig():GetCollectibles().Size - 1
	
    for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasCollectible(CustomCollectibles.HAND_ME_DOWNS) then
			-- actually can't write this into CustomData because lua tables are retarded
			GameOverStage = game:GetLevel():GetStage()
			GameOverItems = {} 
			RNGobj:SetSeed(Random() + 1, 1)
			local freezePreventChecker = 0
			
			repeat
				local roll = RNGobj:RandomInt(maxID) + 1
				freezePreventChecker = freezePreventChecker + 1
				
				if player:HasCollectible(roll) and 
				Isaac.GetItemConfig():GetCollectible(roll).Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST and 
				roll ~= CustomCollectibles.HAND_ME_DOWNS then
					player:RemoveCollectible(roll)
					table.insert(GameOverItems, roll)
				end
			until #GameOverItems == 3 or freezePreventChecker == 1000
		end
	end
	
	CustomData.TaintedHearts.EMPTY = 0
	CustomData.TaintedHearts.ZEALOT = 0
end
rplus:AddCallback(ModCallbacks.MC_POST_GAME_END, rplus.GameEnded)	


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
	
	if command == "rplus_version" then
		print("The current version is: " .. MOD_VERSION .. ". Thanks for playing! :)")
	end
	
	-- TEST COMMAND
	if command == "rplus_test" then
		print('Let\'s test some shit')
		print('!')
		Isaac.ExecuteCommand("macro qk")
		Isaac.ExecuteCommand("g glowing")
		Isaac.ExecuteCommand("g k5")
		Isaac.ExecuteCommand("g roid rage")
	end
end
rplus:AddCallback(ModCallbacks.MC_EXECUTE_CMD, rplus.OnCommandExecute)


						-- MC_POST_NEW_LEVEL --										
						-----------------------
function rplus:OnNewLevel()
	local level = game:GetLevel()
	heartframe = game:GetFrameCount()
	
	if GameOverStage and level:GetStage() == GameOverStage then 
		for _, item in pairs(GameOverItems) do
			Isaac.Spawn(5, 100, item, game:GetRoom():FindFreePickupSpawnPosition(Vector(300, 200)), Vector.Zero, nil):ToPickup()
		end		
		GameOverStage = nil
		GameOverItems = {}	
	end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if CustomData then
			if CustomData.Items.PURE_SOUL.isPortalSuperSecret then
				CustomData.Items.PURE_SOUL.isPortalSuperSecret = false
			else
				CustomData.Items.PURE_SOUL.isPortalSuperSecret = true
			end
			CustomData.Cards.JACK = nil
			CustomData.NumTaintedRocks = 0
			CustomData.Items.CEILING_WITH_THE_STARS.SleptInBed = false
			CustomData.Items.RED_KING.redCrawlspacesData = {}
			CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData = {{index = -1, needToConvert = false},
																  {index = -1, needToConvert = false}}
			
			if player:GetData()['usedDemonForm'] then
				CustomData.Cards.DEMON_FORM.NumUses = 0
				player:GetData()['usedDemonForm'] = false
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
			end
			
			if player:GetData()['enhancedSB'] then
				player:GetData()['enhancedSB'] = false
			end
			
			if player:HasCollectible(CustomCollectibles.BAG_O_TRASH) then
				CustomData.Items.BAG_O_TRASH.Levels = CustomData.Items.BAG_O_TRASH.Levels + 1
			end
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
				newID = GetUnlockedVanillaCollectible(false, false)
				player:AddItemWisp(newID, player.Position, true)
			end
		end
		
		if player:HasCollectible(CustomCollectibles.TWO_PLUS_ONE) then
			CustomData.Items.TWO_PLUS_ONE.ItemsBought_COINS = 0
		end
		
		if player:HasTrinket(CustomTrinkets.BONE_MEAL) then
			CustomData.Trinkets.BONE_MEAL.Levels = CustomData.Trinkets.BONE_MEAL.Levels + player:GetTrinketMultiplier(CustomTrinkets.BONE_MEAL)
			player:UsePill(PillEffect.PILLEFFECT_LARGER, PillColor.PILL_NULL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_MIMIC)
		end
		
		if player:HasCollectible(CustomCollectibles.KEEPERS_PENNY) then
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
		
		if player:HasCollectible(CustomCollectibles.ORDINARY_LIFE) and room:GetType() == RoomType.ROOM_TREASURE 
		and room:IsFirstVisit() and not room:IsMirrorWorld() then
			local momNDadItem = Isaac.Spawn(5, 100, GetUnlockedCollectibleFromCustomPool(CustomItempools.MOMNDAD), room:FindFreePickupSpawnPosition(Vector(320,280), 1, true, false), Vector.Zero, nil):ToPickup()
			
			momNDadItem.OptionsPickupIndex = 3
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity.Type == 5 and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
					entity:ToPickup().OptionsPickupIndex = 3
				end
			end	
		end
		
		if player:HasCollectible(CustomCollectibles.BLACK_DOLL) and room:IsFirstVisit() and Isaac.CountEnemies() > 1 then
			CustomData.Items.BLACK_DOLL.ABSepNumber = math.floor(Isaac.CountEnemies() / 2)
			CustomData.Items.BLACK_DOLL.EntitiesGroupA = {}
			CustomData.Items.BLACK_DOLL.EntitiesGroupB = {}
			local Count = 0
			
			for _, entity in pairs(Isaac.GetRoomEntities()) do
				if entity:IsActiveEnemy(false) and not entity:IsBoss() 
				and entity:IsVulnerableEnemy() then
					Count = Count + 1
					if Count <= CustomData.Items.BLACK_DOLL.ABSepNumber then
						table.insert(CustomData.Items.BLACK_DOLL.EntitiesGroupA, entity)
					else
						table.insert(CustomData.Items.BLACK_DOLL.EntitiesGroupB, entity)
					end
				end
			end
		end
		
		if roomtype == RoomType.ROOM_TREASURE and not room:IsMirrorWorld() then
			if room:IsFirstVisit() then
				if CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[1].index == -1 then 
					CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[1].index = level:GetCurrentRoomDesc().ListIndex
				else
					CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[2].index = level:GetCurrentRoomDesc().ListIndex
				end
				
				for i = 1, 2 do
					if level:GetCurrentRoomDesc().ListIndex == CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[i].index then
						if player:HasTrinket(CustomTrinkets.ANGELS_CROWN) then
							CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[i].needToConvert = true
							
							for _, collectible in pairs(Isaac.FindByType(5, 100, -1, false, false)) do
								cP = collectible:ToPickup()
								local newSubtype = game:GetItemPool():GetCollectible(ItemPoolType.POOL_ANGEL, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL)
								cP:Morph(5, 100, newSubtype, false, false, false)
								cP.ShopItemId = -777
								if Isaac.GetItemConfig():GetCollectible(newSubtype).Quality == 4 then
									cP.Price = player:GetTrinketMultiplier(CustomTrinkets.ANGELS_CROWN) > 1 and 15 or 30
								else
									cP.Price = player:GetTrinketMultiplier(CustomTrinkets.ANGELS_CROWN) > 1 and 7 or 15
								end
								cP.AutoUpdatePrice = false
							end
						else
							CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[i].needToConvert = false
						end
					end
				end
			end
			
			for i = 1, 2 do
				if level:GetCurrentRoomDesc().ListIndex == CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[i].index
				and CustomData.Trinkets.ANGELS_CROWN.treasureRoomsData[i].needToConvert then
					makeRoomAngelShop(room)
				end
			end
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
		
		if player:GetData()['enhancedBoB'] then				
			player:GetData()['enhancedBoB'] = false
			player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
			player:EvaluateItems()
		end
		
		if player:GetData()['usedCursedCard'] then 
			player:GetData()['usedCursedCard'] = false
		end

		if player:GetData()['usedLoadedDice'] then
			player:GetData()['usedLoadedDice'] = false
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
	
		if player:GetData()['usedDemonForm'] 
		and not room:IsClear() and room:IsFirstVisit() then
			if player.Damage <= 2 then
				CustomData.Cards.DEMON_FORM.NumUses = CustomData.Cards.DEMON_FORM.NumUses + (room:GetType() == RoomType.ROOM_BOSS and 2.5 or 0.5)
			elseif player.Damage >= 15 then
				CustomData.Cards.DEMON_FORM.NumUses = CustomData.Cards.DEMON_FORM.NumUses + (room:GetType() == RoomType.ROOM_BOSS and 20 or 4)
			else
				CustomData.Cards.DEMON_FORM.NumUses = CustomData.Cards.DEMON_FORM.NumUses + (room:GetType() == RoomType.ROOM_BOSS and 5 or 1)
			end
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
		end
		
		if player:GetData().RejectionUsed == false then
			player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			player:EvaluateItems()
		end
		
		if player:GetData().JewelData_LUST == "isExtra" then
			player:GetData().JewelData_LUST = nil
		end
		
		if player:HasCollectible(CustomCollectibles.PURE_SOUL) then
			local sinToAnim = {
				[EntityType.ENTITY_SLOTH] = "Sloth",
				[EntityType.ENTITY_LUST] = "Lust",
				[EntityType.ENTITY_WRATH] = "Wrath",
				[EntityType.ENTITY_GLUTTONY] = "Gluttony",
				[EntityType.ENTITY_GREED] = "Greed",
				[EntityType.ENTITY_ENVY] = "Envy",
				[EntityType.ENTITY_PRIDE] = "Pride"
			}
			
			if room:IsFirstVisit() and (room:GetType() == RoomType.ROOM_SUPERSECRET and CustomData.Items.PURE_SOUL.isPortalSuperSecret
			or room:GetType() == RoomType.ROOM_SECRET and not CustomData.Items.PURE_SOUL.isPortalSuperSecret) then
				RNGobj:SetSeed(Random() + 1, 1)
				local sinType = RNGobj:RandomInt(7) + EntityType.ENTITY_SLOTH
				local sinVariant = RNGobj:RandomInt(2)
				
				local soul = Isaac.Spawn(1000, PureSoul, 0, Vector(400, 280), Vector.Zero, player)
				soul:GetSprite():Play(sinToAnim[sinType] .. "_" .. sinVariant)
				player:GetData().PureSoulSin = {sinType, sinVariant}
			end
			
			for i = 0, 7 do
				if room:GetDoor(i) and room:GetDoor(i).TargetRoomType == RoomType.ROOM_MINIBOSS then
					local soul = Isaac.Spawn(1000, PureSoul, 1, room:GetDoorSlotPosition(i), Vector.Zero, player)
					local index = room:GetDoor(i).TargetRoomIndex
					local targetRoom = level:GetRoomByIdx(index, -1)
					local spawns = targetRoom.Data.Spawns
					
					for n = 0, #spawns - 1 do
						local entry = spawns:Get(n):PickEntry(0)
						
						if sinToAnim[entry.Type] then soul:GetSprite():Play(sinToAnim[entry.Type] .. "_" .. entry.Variant) end
					end
					
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.BOOK_OF_JUDGES) then
			CustomData.Items.BOOK_OF_JUDGES.NoBeams = false
			CustomData.Items.BOOK_OF_JUDGES.BeamTargets = {}
			if room:IsFirstVisit() and not room:IsClear() then
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomInt(math.floor(room:GetGridSize() / 15)) + 1 + math.floor(room:GetGridSize() / 30)
				repeat
					-- get random tile-aligned position (just getting a random index won't work because of L-shaped rooms with blind corners)
					local pos = room:GetGridPosition(room:GetGridIndex(room:GetRandomPosition(10)))
					local isNearDoor = false
					
					for i = 0, 7 do
						if room:GetDoorSlotPosition(i):Distance(pos) < 80 then
							isNearDoor = true
						end
					end
					
					if not isNearDoor and room:GetGridEntityFromPos(pos) == nil then
						table.insert(CustomData.Items.BOOK_OF_JUDGES.BeamTargets, pos)
						local beamTarget = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 3, pos, Vector.Zero, nil)
						beamTarget:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_beam_target.png")
						beamTarget:GetSprite():LoadGraphics()
						beamTarget:SetColor(Color(1, 1, 1, 1, 0, 0, 0), 10000, 1, false, false)
					end
				until #CustomData.Items.BOOK_OF_JUDGES.BeamTargets == roll
			end
		end
	end
	
	if CustomData then
		-- handle red crawlspaces spawned by Red King item
		for _, r in pairs(Isaac.FindByType(6, 334, -1, false, false)) do
			if r.SubType == 0 then
				for i, v in pairs(CustomData.Items.RED_KING.redCrawlspacesData) do
					if r.InitSeed == v.seed and v.isRoomDefeated then
						r.SubType = 1
						r:GetSprite():Play("Closed")
						r.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						r.DepthOffset = 10
					end
				end
			else
				r:GetSprite():Play("Closed")
				r.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			end
		end
		
		-- handle Vault of Havoc rooms
		if CustomData.Items.VAULT_OF_HAVOC.Data then  
			-- turning placeholders (black flies) from BR into stored enemies
			for i, placeholder in pairs(Isaac.FindByType(13, 0, 0, false, false)) do
				placeholder:Remove()
				local enemyID = #CustomData.Items.VAULT_OF_HAVOC.EnemyList - i + 1
				if enemyID > 0 then
					local enemy = CustomData.Items.VAULT_OF_HAVOC.EnemyList[enemyID]
					Isaac.Spawn(enemy.Type, enemy.Variant, enemy.SubType, placeholder.Position, Vector.Zero, nil)
					CustomData.Items.VAULT_OF_HAVOC.SumHP = CustomData.Items.VAULT_OF_HAVOC.SumHP + enemy.MaxHitPoints
				end
			end
			
			CustomData.Items.VAULT_OF_HAVOC.EnemiesSpawned = true
			CustomData.Items.VAULT_OF_HAVOC.EnemyList = {}
		elseif CustomData.Items.VAULT_OF_HAVOC.EnemiesSpawned then
			CustomData.Items.VAULT_OF_HAVOC.Data = false 
			CustomData.Items.VAULT_OF_HAVOC.SumHP = 0
			CustomData.Items.VAULT_OF_HAVOC.EnemiesSpawned = false 
		end
		CustomData.TaintedHearts.DAUNTLESS.Data = true
	end
	
	-- handle turning placeholders (Rules Cards) from BR into modded pickups
	for _, placeholder in pairs(Isaac.FindByType(5, 300, Card.CARD_RULES, false, false)) do
		local var = level:GetCurrentRoomDesc().Data.Variant
		local rtype = room:GetType()
		
		if (var == 19245 and rtype == RoomType.ROOM_ERROR)
		or (var == 2929 and rtype == RoomType.ROOM_SECRET) then
			placeholder:ToPickup():Morph(5, 300, CustomConsumables.BAG_TISSUE, true, true, true)
		elseif (rtype == RoomType.ROOM_ARCADE and var >= 2388 and var <= 2391) then
			placeholder:ToPickup():Morph(5, 300, CustomConsumables.LOADED_DICE, true, true, true)
		elseif (rtype == RoomType.ROOM_LIBRARY and var >= 7839 and var <= 7845) then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			if roll < 50 then
				placeholder:ToPickup():Morph(5, 350, CustomTrinkets.EMPTY_PAGE, true, true, true)
			else
				placeholder:ToPickup():Morph(5, 350, CustomTrinkets.TORN_PAGE, true, true, true)
			end
		elseif rtype == RoomType.ROOM_SUPERSECRET then
			if var == 4382 or var == 4383 then
				placeholder:ToPickup():Morph(5, 300, CustomConsumables.MIRRORED_LANDSCAPE, true, true, true)
			elseif var == 4384 then
				placeholder:ToPickup():Morph(5, 300, CustomConsumables.SPIRITUAL_RESERVES, true, true, true)
			end
		end
	end
	
	-- handle bloody rocks placement
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
function rplus:OnGameUpdate()
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
		
		-- some differently colored pills have same effects with PHD/False PHD, and since MC_USE_PILL asks for pill effect, there's no way to
		-- tell them apart and apply the DNA Redactor effect correctly
		blacklistCollectibles(player, CustomCollectibles.DNA_REDACTOR, {CollectibleType.COLLECTIBLE_PHD, CollectibleType.COLLECTIBLE_FALSE_PHD})
		
		-- Mom's Knife and Spirit Sword have like... no difference in code, so while we added Knife synergy, Sword looks severely hurt from that
		-- plus we don't have the Sword resprite for a synergy
		blacklistCollectibles(player, CustomCollectibles.CEREMONIAL_BLADE, CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
		
		-- Satanic Bible + Torn Page override MC_PRE_SPAWN_CLEAN_AWARD, so no red crawlspace will spawn
		-- might seem like a bit of an overkill but it's better this way
		blacklistCollectibles(player, CustomCollectibles.RED_KING, CollectibleType.COLLECTIBLE_SATANIC_BIBLE)
		-----------------------------------------
		
		-- handle temporary dmg boosts
		if player:GetData().flagGiveTempBoost then
			if game:GetFrameCount() % math.floor(1 + 11 / player:GetData().numTempBoosts) == 0 then
				player:GetData().boostTimeStep = player:GetData().boostTimeStep + 1
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
				if player:GetData().boostTimeStep == 50 * player:GetData().numTempBoosts then 
					player:GetData().flagGiveTempBoost = false
					player:GetData().numTempBoosts = 0
					player:GetData().boostTimeStep = 0
				end
			end
		end
		
		if player:GetData()['reverseCardRoom'] and player:GetData()['reverseCardRoom'] ~= game:GetLevel():GetCurrentRoomIndex() then
			player:AnimateCard(CustomConsumables.UNO_REVERSE_CARD, "Pickup")
			for i = 0, 1 do
				if player:GetCard(i) == CustomConsumables.UNO_REVERSE_CARD then player:SetCard(i, 0) end
			end
			player:GetData()['reverseCardRoom'] = nil
		end
		
		if player:HasCollectible(CustomCollectibles.MAGIC_PEN) then
			-- taste the rainbow
			for _, entity in pairs(Isaac.FindByType(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 4, true, false)) do
				local Frame = game:GetFrameCount() % 490 + 1
				
				if Frame <= 140 then	-- RED -> ORANGE -> YELLOW
					local color = Color(1, 1, 1, 1, 0, 0, 0)
					color:SetColorize(1, Frame / 140, 0, 1)
					entity:SetColor(color, 1, 1, false, false)
				elseif Frame <= 210 then	-- YELLOW -> GREEN
					local color = Color(1, 1, 1, 1, 0, 0, 0)
					color:SetColorize(1 - (Frame - 140) / 70, 1, 0, 1)
					entity:SetColor(color, 1, 1, false, false)
				elseif Frame <= 280 then	-- GREEN -> CYAN
					local color = Color(1, 1, 1, 1, 0, 0, 0)
					color:SetColorize(0, 1, (Frame - 210) / 70, 1)
					entity:SetColor(color, 1, 1, false, false)
				elseif Frame <= 350 then	-- CYAN -> BLUE
					local color = Color(1, 1, 1, 1, 0, 0, 0)
					color:SetColorize(0, 1 - (Frame - 280) / 70, 1, 1)
					entity:SetColor(color, 1, 1, false, false)
				elseif Frame <= 420 then	-- BLUE -> MAGENTA
					local color = Color(1, 1, 1, 1, 0, 0, 0)
					color:SetColorize((Frame - 350) / 70, 0, 1, 1)
					entity:SetColor(color, 1, 1, false, false)
				else						-- MAGENTA -> RED
					local color = Color(1, 1, 1, 1, 0, 0, 0)
					color:SetColorize(1, 0, 1 - (Frame - 420) / 70, 1)
					entity:SetColor(color, 1, 1, false, false)
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.MARK_OF_CAIN) 
		and player:GetExtraLives() == 0 
		and CustomData.Items.MARK_OF_CAIN ~= "player revived" then
			if isPlayerDying(player) then
				local PlayerFamiliars = {}
				
				for i = 1, 900 do
					if Isaac.GetItemConfig():GetCollectible(i) and Isaac.GetItemConfig():GetCollectible(i).Type == ItemType.ITEM_FAMILIAR 
					and i ~= CustomCollectibles.MARK_OF_CAIN and player:HasCollectible(i) then
						for j = 1, player:GetCollectibleNum(i, true) do table.insert(PlayerFamiliars, i) end
					end
				end
				
				if #PlayerFamiliars > 0 then
					-- reviving the player and making Enoch tainted
					for i = 0, game:GetNumPlayers() - 1 do
						Isaac.GetPlayer(i):Revive()
						Isaac.GetPlayer(i):SetMinDamageCooldown(40)
					end
					
					CustomData.Items.MARK_OF_CAIN = "player revived"
					sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, 1, 0)
					for _, enoch in pairs(Isaac.FindByType(3, CustomFamiliars.ENOCH, -1, false, false)) do enoch:Remove() end 
					
					for i = 1, #PlayerFamiliars do player:RemoveCollectible(PlayerFamiliars[i]) end
				end
			end
		end
		
		if CustomData and CustomData.Items.TEMPER_TANTRUM.SuperBerserkState and sfx:IsPlaying(SoundEffect.SOUND_BERSERK_END) then 
			CustomData.Items.TEMPER_TANTRUM.SuperBerserkState = false
		end
		if CustomData and CustomData.ErasedEnemies then
			for _, entity in pairs(Isaac.FindInRadius(Vector(320, 280), 1000, EntityPartition.ENEMY)) do
				for i = 1, #CustomData.ErasedEnemies do
					if entity.Type == CustomData.ErasedEnemies[i] then
						Isaac.Spawn(1000, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
						entity:Remove()
					end
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
		
		if player:HasTrinket(CustomTrinkets.PIECE_OF_CHALK) and CustomData 
		and not room:IsClear() and room:IsFirstVisit() then
			if room:GetFrameCount() <=  150 
			and room:GetFrameCount() % 3 == 0 then
				local Powder = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 5, player.Position, Vector.Zero, nil):ToEffect()
				
				Powder:GetSprite():Load("gfx/1000.333_effect_chalk_powder.anm2", true)
				Powder.Timeout = 600 * player:GetTrinketMultiplier(CustomTrinkets.PIECE_OF_CHALK)
				Powder:SetColor(Color(1, 1, 1, 1, 0, 0, 0), 610 * player:GetTrinketMultiplier(CustomTrinkets.PIECE_OF_CHALK), 1, true, false)
				Powder:Update()
			end
		end
		
		if player:HasTrinket(CustomTrinkets.ADAMS_RIB) then
			if isPlayerDying(player) then
				if player:GetTrinketMultiplier(CustomTrinkets.ADAMS_RIB) > 1 then
					SilentUseCard(player, Card.CARD_SOUL_EVE)
				end
				player:TryRemoveTrinket(CustomTrinkets.ADAMS_RIB)
				for i = 0, game:GetNumPlayers() - 1 do
					Isaac.GetPlayer(i):Revive()
					Isaac.GetPlayer(i):SetMinDamageCooldown(40)
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
		
		if CustomData and CustomData.Pills.LAXATIVE.UseFrame and game:GetFrameCount() % 4 == 0 then
			if (game:GetFrameCount() <= CustomData.Pills.LAXATIVE.UseFrame + 90 and player:GetData()['usedLax'])
			or (game:GetFrameCount() <= CustomData.Pills.LAXATIVE.UseFrame + 360 and player:GetData()['usedHorseLax']) then
				local vector = Vector.FromAngle(DIRECTION_VECTOR[player:GetMovementDirection()]:GetAngleDegrees() + math.random(-15, 15)):Resized(-7.5)
				local SCorn = Isaac.Spawn(2, CustomTearVariants.CORN, 0, player.Position, vector, Player):GetSprite()
				
				SCorn:Play("Big0" .. math.random(4))
				cornScale = math.random(5, 10) / 10
				SCorn.Scale = Vector(cornScale, cornScale)
			else
				CustomData.Pills.LAXATIVE.UseFrame = nil
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
		
		if CustomData and CustomData.Pills.PHANTOM_PAINS.UseFrame and (game:GetFrameCount() - CustomData.Pills.PHANTOM_PAINS.UseFrame) % 600 == 1 then
			if game:GetFrameCount() <= CustomData.Pills.PHANTOM_PAINS.UseFrame + 1300 
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
		
		if player:HasCollectible(CustomCollectibles.SCALPEL) and game:GetFrameCount() % 6 == 0 
		and player:GetFireDirection() ~= Direction.NO_DIRECTION then
			local RedTear = player:FireTear(player.Position + DIRECTION_VECTOR[player:GetFireDirection()] * 45, Vector.FromAngle(DIRECTION_VECTOR[player:GetFireDirection()]:GetAngleDegrees() + math.random(-10, 10)):Resized(-8), false, true, false, player, 0.75)
			RedTear.FallingAcceleration = 0.8
			RedTear.FallingSpeed = -7
			if RedTear.Variant ~= TearVariant.BLOOD then RedTear:ChangeVariant(TearVariant.BLOOD) end
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
						player:SetMinDamageCooldown(40)
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
				crippleEnemy(enemy)
			end
		end	
		
		if player:HasCollectible(CustomCollectibles.RED_MAP) 
		and not CustomData.Items.RED_MAP.ShownOnFloorOne then
			local USR = level:GetRoomByIdx(level:QueryRoomTypeIndex(RoomType.ROOM_ULTRASECRET, true, RNG(), true))
			
			if USR.Data and USR.Data.Type == RoomType.ROOM_ULTRASECRET and USR.DisplayFlags & 1 << 2 == 0 then
				USR.DisplayFlags = USR.DisplayFlags | 1 << 2
				level:UpdateVisibility()
			end
			CustomData.Items.RED_MAP.ShownOnFloorOne = true
		end

		-- balancing the amount of active (main) and passive (technical) Rejection items
		if player:GetCollectibleNum(CustomCollectibles.REJECTION) > player:GetCollectibleNum(CustomCollectibles.REJECTION_P) then
			player:AddCollectible(CustomCollectibles.REJECTION_P)
		elseif player:GetCollectibleNum(CustomCollectibles.REJECTION) < player:GetCollectibleNum(CustomCollectibles.REJECTION_P) then
			player:RemoveCollectible(CustomCollectibles.REJECTION_P)
		end
		
		if player:HasCollectible(CustomCollectibles.MAGIC_MARKER) and not CustomData.Items.MAGIC_MARKER.CardDrop then
			CustomData.Items.MAGIC_MARKER.CardDrop = true
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomInt(22) + 1
			local isReversed = RNGobj:RandomInt(2) * 55		-- normal Fool is CARD 1, reversed Fool? is CARD 56
			
			Isaac.Spawn(5, 300, roll + isReversed, Isaac.GetFreeNearPosition(player.Position, 10), Vector.Zero, player)
		end
		
		if player:GetData().isSavageHeartBoosted and game:GetFrameCount() % 15 == 0 then
			player:GetData().savageTimeStep = player:GetData().savageTimeStep + 1
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
			player:EvaluateItems()
			if player:GetData().savageTimeStep == 50 then
				player:GetData().savageTimeStep = 0
				player:GetData().isSavageHeartBoosted = false
			end
		end
		
		if player:HasCollectible(CustomCollectibles.PURE_SOUL) and player:GetData().PureSoulSin then
			for _, ps in pairs(Isaac.FindByType(1000, 777, 0)) do
				if player.Position:Distance(ps.Position) < 20 then
					Isaac.Spawn(player:GetData().PureSoulSin[1], player:GetData().PureSoulSin[2], 0, Vector(320, 280), Vector.Zero, nil)
					Isaac.Spawn(1000, EffectVariant.POOF01, 0, ps.Position, Vector.Zero, player)
					ps:Remove()
					
					for i = 0, 8 do
						local door = room:GetDoor(i)
						if door then 
							door:Bar()
						end
					end
				end
			end
		end
		
		if player:HasCollectible(CustomCollectibles.BOOK_OF_JUDGES) and not CustomData.Items.BOOK_OF_JUDGES.NoBeams 
		and #Isaac.FindByType(1000, EffectVariant.TARGET, 3) and not room:IsClear() 
		and room:GetFrameCount() % 90 == 45 then
			for _, pos in pairs(CustomData.Items.BOOK_OF_JUDGES.BeamTargets) do
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, pos, Vector.Zero, nil)
				for _, enemy in pairs(Isaac.FindInRadius(pos, 15, EntityPartition.ENEMY)) do
					local burnMult = player:HasTrinket(CustomTrinkets.TORN_PAGE) and 2 or 1
					
					enemy:AddBurn(EntityRef(player), 45 * burnMult, 3.5 * burnMult)
				end
			end
		end		
		
		if heartframe and game:GetFrameCount() == heartframe + 1 and CustomData and i == 0 then 
			for j = 1, CustomData.TaintedHearts.ZEALOT do
				newID = GetUnlockedVanillaCollectible(false, false)
				player:AddItemWisp(newID, player.Position, true)
			end
			
			for j = 1, CustomData.TaintedHearts.EMPTY do
				-- Abyss Locusts of any subtype greater than 0 don't disappear when the player's familiar cache is re-evaluated
				-- ???
				local locust = Isaac.Spawn(3, FamiliarVariant.ABYSS_LOCUST, 77, player.Position, Vector.Zero, player):ToFamiliar()
			end
			
			heartframe = 0
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
			repeat
				newID = GetUnlockedVanillaCollectible(true, true)
			until Isaac.GetItemConfig():GetCollectible(colResult).Tags & ItemConfig.TAG_STARS == ItemConfig.TAG_STARS
			Isaac.Spawn(5, 100, newID, Isaac.GetFreeNearPosition(Vector(sg.Position.X, sg.Position.Y + 40), 40), Vector.Zero, nil)
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

	-- Soul Bond
	for _, enemy in pairs(Isaac.FindInRadius(Vector(320, 280), 400, EntityPartition.ENEMY)) do
		-- enemies colliding with Soul Bond chains
		if isCollidingWithAstralChain(enemy) and game:GetFrameCount() % 3 == 0 then
			enemy:TakeDamage(stage * 0.5, 0, EntityRef(enemy), 0)
		end
	end
	for _, chain in pairs(Isaac.FindByType(865, 10, 1, true, false)) do
		-- removing the chain if the target is dead; chained enemies have a 33% chance to drop a soul heart when killed
		if not chain.Target or chain.Target:IsDead() then 
			chain:Remove()
			if math.random(100) < SOUL_BOND_HEARTDROP_CHANCE then Isaac.Spawn(5, 10, HeartSubType.HEART_SOUL, chain.Target.Position, Vector.Zero, nil) end
		-- breaking the chain if you get too far away from enemy or if the boss is chained for longer than 5 seconds
		elseif math.abs((chain.Parent.Position - chain.Target.Position):Length()) > 350 
		or (chain.Target and chain.Target:IsBoss() and game:GetFrameCount() >= chain.Target:GetData()['chainedOnFrame'] + 150) then
			chain:Remove()
			chain.Target:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
			sfx:Play(SoundEffect.SOUND_ANIMA_BREAK, 1, 2, false, 1, 0)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_UPDATE, rplus.OnGameUpdate)


						-- MC_USE_ITEM --										
						-----------------
function rplus:OnItemUse(ItemUsed, _, Player, UseFlags, Slot, _)
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
		for i = 1, 3 do
			Player:AddMinisaac(Player.Position, true)
		end
		sfx:Play(SoundEffect.SOUND_BLOODBANK_SPAWN, 1, 2, false, 1, 0)
		Player:GetData()['graterUsed'] = true
		
		CustomData.Items.CHEESE_GRATER.NumUses = CustomData.Items.CHEESE_GRATER.NumUses + 1
		Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		Player:EvaluateItems()
	end
	
	if ItemUsed == CustomCollectibles.RUBIKS_CUBE and UseFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED then
		RNGobj:SetSeed(Random() + 1, 1)
		local solveChance = RNGobj:RandomInt(100) + 1
		
		if solveChance <= 5 or CustomData.Items.RUBIKS_CUBE.Counter == 20 then
			Player:RemoveCollectible(CustomCollectibles.RUBIKS_CUBE, true, ActiveSlot.SLOT_PRIMARY, true)
			Player:AddCollectible(CustomCollectibles.MAGIC_CUBE, 4, true, ActiveSlot.SLOT_PRIMARY, 0)
			Player:AnimateHappy()
			CustomData.Items.RUBIKS_CUBE.Counter = 0
			return false
		else
			CustomData.Items.RUBIKS_CUBE.Counter = CustomData.Items.RUBIKS_CUBE.Counter + 1
			return true
		end
	end
	
	if ItemUsed == CustomCollectibles.MAGIC_CUBE then
		for _, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == 5 and entity.Variant == 100 and entity.SubType > 0 then
				entity:ToPickup():Morph(5, 100, GetUnlockedVanillaCollectible(true, true), true, false, true)
			end
		end
		return true
	end
	
	if ItemUsed == CustomCollectibles.QUASAR then
		properQuasarUse(Player)
		return {Discharge = true, Remove = false, ShowAnim = true}
	end
	
	if ItemUsed == CustomCollectibles.TOWER_OF_BABEL then
		for g = 1, room:GetGridSize() do
			if room:GetGridEntity(g) then room:GetGridEntity(g):Destroy() end
		end
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 200, EntityPartition.ENEMY)) do
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy(false) and not enemy:IsBoss() then
				enemy:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
			end
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
		or freezePreventChecker == 1000
		
		if freezePreventChecker < 1000 then
			Player:AnimateCollectible(ID, "UseItem", "PlayerPickupSparkle")
			Player:RemoveCollectible(ID, true, -1, true)
		
			local Q = Isaac.GetItemConfig():GetCollectible(ID).Quality
			for i = 1, (Player:HasTrinket(CustomTrinkets.TORN_PAGE) and 4 or 3) do
				repeat 
					newID = GetUnlockedVanillaCollectible(true, false)
				until  Isaac.GetItemConfig():GetCollectible(newID).Quality == Q
				
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
		-- Bible removes one broken heart
		if ItemUsed == CollectibleType.COLLECTIBLE_BIBLE then
			Player:AddBrokenHearts(-2)
		
		-- Book of the Dead gives you a bone heart
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD then
			Player:AddBoneHearts(1)
		
		-- Book of Belial also grants eye of belial effect for the room
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL then
			Player:GetData()['enhancedBoB'] = true
			Player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
			Player:EvaluateItems()		
		
		-- Telepathy for Dummies also grants dunce cap effect for the room
		elseif ItemUsed == CollectibleType.COLLECTIBLE_TELEPATHY_BOOK then
			Player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_THE_WIZ, true, 1)
		
		-- Necronomicon spawns 3 locusts of death on use
		elseif (ItemUsed == CollectibleType.COLLECTIBLE_NECRONOMICON and UseFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED) then
			for i = 1, 3 do
				Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_DEATH, Player.Position, Vector.Zero, Player)
			end
		
		-- Book of Shadows has extended shield duration
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS then
			SilentUseCard(Player, Card.RUNE_ALGIZ)
		
		-- Book of Secrets & Monster Manual get 2 charges back when used
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS 
		or ItemUsed == CollectibleType.COLLECTIBLE_MONSTER_MANUAL then
			Player:SetActiveCharge(Player:GetActiveCharge(Slot) + 2, Slot)
		
		-- Satanic Bible gives you 2 devil deals to choose from
		elseif ItemUsed == CollectibleType.COLLECTIBLE_SATANIC_BIBLE then
			Player:GetData()['enhancedSB'] = true
			
		elseif ItemUsed == CollectibleType.COLLECTIBLE_LEMEGETON then
			Player:GetData()['usedLem'] = true
		end
	end
	
	if Player:HasTrinket(CustomTrinkets.EMPTY_PAGE) then
		if Isaac.GetItemConfig():GetCollectible(ItemUsed).Tags & ItemConfig.TAG_BOOK == ItemConfig.TAG_BOOK
		and ItemUsed ~= CollectibleType.COLLECTIBLE_HOW_TO_JUMP
		and UseFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED then
			for i = 1, Player:GetTrinketMultiplier(CustomTrinkets.EMPTY_PAGE) do
				Player:UseActiveItem(CustomItempools.EMPTYPAGEACTIVES[math.random(#CustomItempools.EMPTYPAGEACTIVES)], UseFlag.USE_NOANIM, -1)
			end
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
		if not Player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION, false) then
			Player:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_C_SECTION), true)
		end
		Player:GetData().FamiliarsInBelly = {}
		Player:GetData().RejectionAnimName = "Spin"
		
		for _, lil in pairs(Isaac.FindByType(3, -1, -1, false, true)) do
			if lil:ToFamiliar() and lil:ToFamiliar().IsFollower 
			and not (lil.Variant == FamiliarVariant.INCUBUS and Player:GetPlayerType() == PlayerType.PLAYER_LILITH) then
				table.insert(Player:GetData().FamiliarsInBelly, lil.Variant)
				if lil.Variant == FamiliarVariant.INCUBUS or lil.Variant == FamiliarVariant.LIL_ABADDON or lil.Variant == FamiliarVariant.DEMON_BABY 
				or lil.Variant == FamiliarVariant.LIL_BRIMSTONE then
					Player:GetData().RejectionAnimName = "Spin_demon"
				elseif lil.Variant == FamiliarVariant.SERAPHIM or lil.Variant == CustomFamiliars.CHERUBIM then
					Player:GetData().RejectionAnimName = "Spin_angel"
				end
				lil:Remove()
			end
		end
		if #Player:GetData().FamiliarsInBelly == 1 then Player:GetData().RejectionAnimName = "Spin_fetusonly" end
		if #Player:GetData().FamiliarsInBelly > 0 then
			Player:GetData().RejectionUsed = true -- for repeatedly deleting familiars afterwards
			sfx:Play(SoundEffect.SOUND_VAMP_GULP, 1, 2, false, 1, 0)
		end
	end
	
	if ItemUsed == CustomCollectibles.AUCTION_GAVEL then
		Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
		sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 1, 2, false, 1, 0)
		local auctionCollectible = Isaac.Spawn(5, 100, GetUnlockedVanillaCollectible(false), Isaac.GetFreeNearPosition(Player.Position, 40), Vector.Zero, Player):ToPickup()
		auctionCollectible.AutoUpdatePrice = false
		auctionCollectible.Price = Player:HasCollectible(CollectibleType.COLLECTIBLE_STEAM_SALE) and 10 or 22
		auctionCollectible.ShopItemId = -321
		auctionCollectible:GetData().Data = Player:HasCollectible(CollectibleType.COLLECTIBLE_STEAM_SALE) and "sale price" or "normal price"
	end
	
	if ItemUsed == CustomCollectibles.SOUL_BOND then
		local en = {}
		for _, ent in pairs(Isaac.FindInRadius(Player.Position, 275, EntityPartition.ENEMY)) do
			if ent:IsVulnerableEnemy()
			-- killing a chained Heart doesn't kill its Mask, causing a softlock :p
			and ent.Type ~= EntityType.ENTITY_HEART then table.insert(en, ent) end
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
			if astralChain.Target:IsBoss() then astralChain.Target:GetData()['chainedOnFrame'] = game:GetFrameCount() end
			
			return {Discharge = true, Remove = false, ShowAnim = true}
		else
			return {Discharge = false, Remove = false, ShowAnim = false}
		end
	end
	
	if ItemUsed == CustomCollectibles.BOOK_OF_LEVIATHAN then
		if not room:IsClear()
		and (Player:GetNumKeys() > 0 or Player:HasGoldenKey() or Player:HasTrinket(CustomTrinkets.TORN_PAGE)) then
			if not Player:HasGoldenKey() and not Player:HasTrinket(CustomTrinkets.TORN_PAGE) then Player:AddKeys(-1) end
			RNGobj:SetSeed(Random() + 1, 1)
			
			for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 1200, EntityPartition.ENEMY)) do
				if crippleEnemy(enemy) then
					local roll = RNGobj:RandomFloat() * 100
					local pickupRoll = (RNGobj:RandomInt(3) + 2) * 10
					
					if Player:HasTrinket(TrinketType.TRINKET_STRANGE_KEY) and roll < 75 then 
						local Flags = {
							EntityFlag.FLAG_POISON, 
							EntityFlag.FLAG_SLOW, 
							EntityFlag.FLAG_CHARM, 
							EntityFlag.FLAG_CONFUSION, 
							EntityFlag.FLAG_FEAR, 
							EntityFlag.FLAG_BURN
						}
						
						enemy:AddEntityFlags(Flags[math.random(#Flags)])
					elseif Player:HasTrinket(TrinketType.TRINKET_GILDED_KEY) and roll < 25 then enemy:AddMidasFreeze(EntityRef(Player), 90)
					elseif Player:HasTrinket(TrinketType.TRINKET_CRYSTAL_KEY) and roll < 25 then enemy:AddEntityFlags(EntityFlag.FLAG_ICE)
					elseif Player:HasTrinket(TrinketType.TRINKET_BLUE_KEY) and roll < 15 then enemy:GetData().dropSoulHeart = true
					elseif Player:HasTrinket(TrinketType.TRINKET_RUSTED_KEY) and roll < 50 then enemy:AddConfusion(EntityRef(Player), 90, true)
					elseif Player:HasTrinket(TrinketType.TRINKET_STORE_KEY) and roll < 75 then enemy:GetData().dropPickup = pickupRoll
					elseif Player:HasTrinket(CustomTrinkets.BASEMENT_KEY) and roll < 50 then enemy:GetData().spawnBoneOrbital = true
					elseif Player:HasTrinket(CustomTrinkets.KEY_TO_THE_HEART) and roll < 40 then enemy:GetData().dropRedHeart = true  
					elseif Player:HasTrinket(CustomTrinkets.KEY_KNIFE) and roll < 75 then enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT) end
				end
			end	
			
			-- playing giantbook animation (tricky trick by Bogdan Ryduka)
			SilentUseCard(Player, Card.RUNE_BERKANO)
			for _, bluefly in pairs(Isaac.FindByType(3, FamiliarVariant.BLUE_FLY, -1)) do
				if bluefly:Exists() and bluefly.FrameCount <= 0 then
					bluefly:Remove()
				end
			end
			for _, bluespider in pairs(Isaac.FindByType(3, FamiliarVariant.BLUE_SPIDER, -1)) do
				if bluespider:Exists() and bluespider.FrameCount <= 0 then
					bluespider:Remove()
				end
			end
			
			LeviathanGiantBookAnim:Load("gfx/ui/giantbook/giantbook_bookofleviathan.anm2", true)
			LeviathanGiantBookAnim:Play("Shake", true)
			fakeBerkanoCall = true
			animLength = 36
			
			return {Discharge = true, Remove = false, ShowAnim = true}
		else
			return {Discharge = false, Remove = false, ShowAnim = true}
		end
	end
	
	if ItemUsed == CustomCollectibles.MAGIC_MARKER then
		local primaryCard = Player:GetCard(0)
		
		if primaryCard >= Card.CARD_FOOL and primaryCard <= Card.CARD_WORLD then	-- normal tarots
			if primaryCard == Card.CARD_WORLD then
				Player:SetCard(0, Card.CARD_FOOL)
			else
				Player:SetCard(0, primaryCard + 1)
			end
			
			return {Discharge = true, Remove = false, ShowAnim = true}
		elseif primaryCard >= Card.CARD_REVERSE_FOOL and primaryCard <= Card.CARD_REVERSE_WORLD then	-- reversed tarots
			if primaryCard == Card.CARD_REVERSE_FOOL then
				Player:SetCard(0, Card.CARD_REVERSE_WORLD)
			else
				Player:SetCard(0, primaryCard - 1)
			end
			
			return {Discharge = true, Remove = false, ShowAnim = true}
		else																		-- WIP (runes, soulstones, playing cards and objects)
			return {Discharge = false, Remove = false, ShowAnim = false}
		end
	end
	
	if ItemUsed == CustomCollectibles.VAULT_OF_HAVOC then  
		if #CustomData.Items.VAULT_OF_HAVOC.EnemyList >= 12 then 
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomInt(5) + 1
			
			Isaac.ExecuteCommand("goto s.boss." .. roll + 55000)
			CustomData.Items.VAULT_OF_HAVOC.Data = true
			return {Discharge = true, Remove = false, ShowAnim = true} 
		else
			--sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 2, false, 1, 0)
			return {Discharge = false, Remove = false, ShowAnim = true}
		end  
	end
	
	if ItemUsed == CustomCollectibles.HANDICAPPED_PLACARD then
		if not isRoomFightInProgress(room) then
			return {Discharge = false, Remove = false, ShowAnim = true}
		else
			local placard = Isaac.Spawn(3, CustomFamiliars.HANDICAPPED_PLACARD, 0, Player.Position, Vector.Zero, Player)
			local eff = Isaac.Spawn(1000, PlacardBorder, 0, placard.Position, Vector.Zero, placard):ToEffect()
			eff.SpriteScale = Vector(2.75, 2.75)
		end
	end
	
	if ItemUsed == CustomCollectibles.BOOK_OF_JUDGES then
		CustomData.Items.BOOK_OF_JUDGES.NoBeams = true
		return {Discharge = true, Remove = false, ShowAnim = true}
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_ITEM, rplus.OnItemUse)


						-- MC_USE_CARD -- 										
						-----------------
function rplus:OnCardUse(CardUsed, Player, _)	
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
	
	if room:GetType() ~= RoomType.ROOM_BOSS and room:GetType() ~= RoomType.ROOM_BOSSRUSH then
		local NumPickups = 0
		
		if CardUsed == CustomConsumables.KING_OF_SPADES then
			sfx:Play(SoundEffect.SOUND_GOLDENKEY, 1, 2, false, 1, 0)
			NumPickups = math.min(math.floor(Player:GetNumKeys() / 3), 11)
			Player:AddKeys(-math.min(Player:GetNumKeys(), 33))
			if Player:HasGoldenKey() then Player:RemoveGoldenKey() NumPickups = NumPickups + 2 end
		elseif CardUsed == CustomConsumables.KING_OF_CLUBS then
			NumPickups = math.min(math.floor(Player:GetNumBombs() / 3), 11)
			Player:AddBombs(-math.min(Player:GetNumBombs(), 33))
			if Player:HasGoldenBomb() then Player:RemoveGoldenBomb() NumPickups = NumPickups + 2 end
		elseif CardUsed == CustomConsumables.KING_OF_DIAMONDS then
			NumPickups = math.min(math.floor(Player:GetNumCoins() / 6), 11)
			Player:AddCoins(-math.min(Player:GetNumCoins(), 66))
		end
		
		if NumPickups > 0 then
			for i = 1, NumPickups do
				room:SpawnClearAward()
			end
			
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			if roll < 25 * NumPickups then Isaac.Spawn(5, 350, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, Player) end
			if roll < 14 * NumPickups then Isaac.Spawn(5, 100, 0, Player.Position + Vector.FromAngle(math.random(360)) * 20, Vector.Zero, Player) end
		end
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
				ID = GetUnlockedVanillaCollectible(true, false)
			until Isaac.GetItemConfig():GetCollectible(ID).Quality == DesiredQuality
			
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
		
		properQuasarUse(Player)
	end
	
	if CardUsed == CustomConsumables.SACRIFICIAL_BLOOD and CustomData then
		addTemporaryDmgBoost(Player)
		
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
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 860, EntityPartition.ENEMY)) do
			if enemy:IsVulnerableEnemy() then
				local knifeTear = Isaac.Spawn(1000, FallingKnifeHelper, 0, enemy.Position, Vector.Zero, enemy)
				knifeTear:GetData().Damage = Player.Damage * 2
			end
		end
	end
	
	if CardUsed == CustomConsumables.ANTIMATERIAL_CARD then
		local antimaterialCardTear = Isaac.Spawn(2, CustomTearVariants.ANTIMATERIAL_CARD, 0, Player.Position, DIRECTION_VECTOR[Player:GetMovementDirection()]:Resized(10), Player)
		antimaterialCardTear:GetSprite():Play("Rotate")
	end
	
	if CardUsed == CustomConsumables.VALENTINES_CARD then
		local valentinesTear = Isaac.Spawn(2, CustomTearVariants.VALENTINES_CARD, 0, Player.Position, DIRECTION_VECTOR[Player:GetMovementDirection()]:Resized(10), Player)
		valentinesTear:GetSprite():Play("Rotate")
		Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, Player.Position, Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_KISS_LIPS1, 1, 2, false, 1, 0)
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
			
			if Counter == 80 or Player:GetNumKeys() + Player:GetNumBombs() + Player:GetNumCoins() == 0 then 
				break 
			end 
		end
		
		if Counter >= 3 and Counter <= 20 then 
		-- enemies take damage and are set on fire
			for _, enemy in pairs(Isaac.GetRoomEntities()) do
				if enemy:IsVulnerableEnemy() then 
					enemy:TakeDamage(15, 1, EntityRef(Player), 0)
					enemy:AddBurn(EntityRef(Player), 120, Player.Damage)
				end
			end
		elseif Counter > 20 and Counter <= 40 then 
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
		elseif Counter > 40 and Counter <= 80 then 
		-- produce mama mega explosion, longer burn duration
			Isaac.Spawn(1000, 127, 0, Player.Position, Vector.Zero, nil)
			for _, enemy in pairs(Isaac.GetRoomEntities()) do
				if enemy:IsVulnerableEnemy() then 
					enemy:AddBurn(EntityRef(Player), 480, 4 * Player.Damage)
				end
			end 
		end
		
		sfx:Play(SoundEffect.SOUND_WAR_HORSE_DEATH, 1, 2, false, 1, 0)
		game:ShakeScreen(30)
	end
	
	-- opening Scarlet chests via Soul of Cain
	if CardUsed == Card.CARD_SOUL_CAIN then
		for _, chest in pairs(Isaac.FindByType(5, CustomPickups.SCARLET_CHEST, -1, false, false)) do
			if chest.SubType == 0 or chest.SubType == 2 then
				openScarletChest(chest)
			end
		end
	end
	
	-- backwards compatibility for Berkano Rune
	if CardUsed == Card.RUNE_BERKANO and not fakeBerkanoCall then
		LeviathanGiantBookAnim:Load("gfx/ui/giantbook/giantbook.anm2", true)
		LeviathanGiantBookAnim:ReplaceSpritesheet(0, "gfx/ui/giantbook/Rune_07_Berkand.png")
		LeviathanGiantBookAnim:LoadGraphics()
		LeviathanGiantBookAnim:Play("Appear", true)
		animLength = 33
	end
	
	if CardUsed == CustomConsumables.SPIRITUAL_RESERVES then
		Player:GetData()['usedSpiritualReserves'] = {true, true}
		Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
		Player:EvaluateItems()
	end
	
	if CardUsed == CustomConsumables.MIRRORED_LANDSCAPE then
		local primaryActive = Player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
		local pocketActive = Player:GetActiveItem(ActiveSlot.SLOT_POCKET)
		
		if primaryActive ~= 0 
		and not isItemPocketSlotBlacklisted(primaryActive) then
			if pocketActive ~= 0 then
				Player:RemoveCollectible(pocketActive)
				Isaac.Spawn(5, 100, pocketActive, game:GetRoom():FindFreePickupSpawnPosition(Player.Position, 0, true, false), Vector.Zero, nil)
			end
			Player:RemoveCollectible(primaryActive)
			Player:SetPocketActiveItem(primaryActive, ActiveSlot.SLOT_POCKET, false)
		end
	end
	
	if CardUsed == CustomConsumables.CURSED_CARD then
		Player:GetData()['usedCursedCard'] = true
		Player:GetData()['getBrokenHearts'] = 0
		sfx:Play(SoundEffect.SOUND_DEVIL_CARD)
	end
	
	-- JEWELS --
	if CardUsed == CustomConsumables.CROWN_OF_GREED then
		RNGobj:SetSeed(Random() + 1, 1)
		local roll = RNGobj:RandomInt(2) + 1
		
		local d = Player:GetData().JewelData_GREED
		if not d then d = roll else d = d + roll end
		Player:GetData().JewelData_GREED = d
		
		for i = 1, roll do
			Isaac.Spawn(5, 20, CoinSubType.COIN_GOLDEN, Isaac.GetFreeNearPosition(Player.Position, 20), Vector.Zero, nil)
		end
		Player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		Player:EvaluateItems()
	end
	
	if CardUsed == CustomConsumables.FLOWER_OF_LUST then
		Player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, false, false, true, false, -1)
		Player:GetData().JewelData_LUST = "isExtra"
	end
	
	if CardUsed == CustomConsumables.ACID_OF_SLOTH then
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 1500, EntityPartition.ENEMY)) do
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy(false) and not enemy:IsBoss() then
				enemy:AddSlowing(EntityRef(Player), 1000, 0.5, Color(0.08, 0.3, 0.05, 1, 0, 0, 0))
				enemy:GetData().isSpawningCreep = true
			end
		end
	end
	
	if CardUsed == CustomConsumables.VOID_OF_GLUTTONY then
		local totalHP = 0
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 1500, EntityPartition.ENEMY)) do
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy(false) and not enemy:IsBoss() then
				totalHP = totalHP + enemy.MaxHitPoints
				enemy:Kill()
			end
		end
		
		RNGobj:SetSeed(Random() + 1, 1)
		local roll = RNGobj:RandomFloat() * 100
		if roll < (1 + totalHP / 40) * 10 then
			sfx:Play(SoundEffect.SOUND_VAMP_GULP)
            Player:AddMaxHearts(2, true)
		else
			sfx:Play(SoundEffect.SOUND_BOSS_SPIT_BLOB_BARF)
			local tear = Player:FireTear(Player.Position, DIRECTION_VECTOR[Player:GetHeadDirection()] * 6, false, true, false, Player, 0):ToTear()
			tear.Scale = 3
			tear:SetColor(Color(0.5, 0.1, 0.05, 1, 0, 0, 0), 1000, 1, false, false)
			tear.FallingSpeed = -10
			tear.FallingAcceleration = 0.6
			tear:GetData()['spawnsGuts'] = true
		end
	end
	
	if CardUsed == CustomConsumables.APPLE_OF_PRIDE then
		Player:GetData()['prideStatBoosts'] = true
		Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_RANGE)
		Player:EvaluateItems()
	end
	
	if CardUsed == CustomConsumables.CANINE_OF_WRATH then
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 1500, EntityPartition.ENEMY)) do
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy(false) then
				local bomb = Isaac.Spawn(4, 0, 0, enemy.Position, Vector.Zero, enemy):ToBomb()
				bomb.ExplosionDamage = 15.1
				bomb:SetExplosionCountdown(1)
				bomb.Visible = false
				
				if enemy.HitPoints <= 15 then
					addTemporaryDmgBoost(Player)
				end
			end
		end
	end
	
	if CardUsed == CustomConsumables.MASK_OF_ENVY then
		Player:GetData()['envyTearsBoost'] = Player:GetData()['envyTearsBoost'] and Player:GetData()['envyTearsBoost'] + 1 or 1
		Player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		Player:EvaluateItems()
		if Player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER_B and Player:GetPlayerType() ~= PlayerType.PLAYER_KEEPER then
			local hearts = Player:GetMaxHearts()
			Player:AddMaxHearts(-hearts)
			Player:AddBoneHearts(hearts / 2)
			Player:AddRottenHearts(hearts)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_CARD, rplus.OnCardUse)


						-- MC_USE_PILL --	
						-----------------
function rplus:OnPillUse(pillEffect, Player, _)
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
			Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, 0, Player.Position, Vector.Zero, Player)
		end
	end
	
	if pillEffect == CustomPills.LAXATIVE then
		if pillColor < 2048 then
			Player:GetData()['usedLax'] = true
		else
			Player:GetData()['usedHorseLax'] = true	-- increased duration for horse pill
		end
		CustomData.Pills.LAXATIVE.UseFrame = game:GetFrameCount()
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
		CustomData.Pills.PHANTOM_PAINS.UseFrame = game:GetFrameCount()
	end
	
	if pillEffect == CustomPills.YUCK and CustomData then
		if pillColor < 2048 then
			Player:GetData()['usedYuck'] = true
		else
			Player:GetData()['usedHorseYuck'] = true	-- increased duration for horse pill
		end
		CustomData.Pills.YUCK.UseFrame = game:GetFrameCount()
		Isaac.Spawn(5, 10, 12, Player.Position, Vector.Zero, nil)
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
	end
	
	if pillEffect == CustomPills.YUM and CustomData then
		if pillColor < 2048 then
			Player:GetData()['usedYum'] = true
		else
			Player:GetData()['usedHorseYum'] = true	-- increased duration for horse pill
		end
		CustomData.Pills.YUM.UseFrame = game:GetFrameCount()
		RNGobj:SetSeed(Random() + 1, 1)
		local roll = RNGobj:RandomInt(4) + 2
		for i = 1, roll do
			Isaac.Spawn(5, 10, 2, Isaac.GetFreeNearPosition(Player.Position, 10), Vector.Zero, nil)
		end
		sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
	end
end
rplus:AddCallback(ModCallbacks.MC_USE_PILL, rplus.OnPillUse)


						-- MC_POST_PLAYER_UPDATE --									
						---------------------------
function rplus:PostPlayerUpdate(Player)
	-- this callback handles inputs, because it rolls in 60 fps, unlike MC_POST_UPDATE, so inputs won't be missed out
	local level = game:GetLevel()
	local room = game:GetRoom()
	
	if Input.IsButtonTriggered(Keyboard.KEY_H, Player.ControllerIndex) and not hideErrorMessage then
		print('Error message hidden. To see it again, type `show` into the console')
		hideErrorMessage = true
	end	
	
	-- helper for reading double tap
	for i = 4, 7 do 
		-- shooting left, right, up, down; reading first input
		if Input.IsActionTriggered(i, Player.ControllerIndex) and not Player:GetData().ButtonState then
			Player:GetData().ButtonPressed = i
			Player:GetData().ButtonState = "listening for second tap"
			Player:GetData().PressFrame = game:GetFrameCount()
			--print('button ' .. Player:GetData().ButtonPressed .. ' is pressed on frame ' .. Player:GetData().PressFrame)
		end
		
		if Player:GetData().PressFrame and game:GetFrameCount() <= Player:GetData().PressFrame + 6 then 
			-- listening for next inputs in the next 6 frames
			if not Input.IsActionTriggered(Player:GetData().ButtonPressed, Player.ControllerIndex) 
			and Player:GetData().ButtonState == "listening for second tap" then
				Player:GetData().ButtonState = "button released"
			end
			
			if Player:GetData().ButtonState == "button released" 
			and Input.IsActionTriggered(Player:GetData().ButtonPressed, Player.ControllerIndex) then
				-- ITEM DOUBLE TAP MECHANICS HERE
				---------------------------------
				
				-- Enraged Soul
				if Player:HasCollectible(CustomCollectibles.ENRAGED_SOUL) and not room:IsClear() and
				(not CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown or CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown <= 0) then
					if (Player:GetData().ButtonPressed == 4 and not room:IsMirrorWorld()) or (Player:GetData().ButtonPressed == 5 and room:IsMirrorWorld()) then
						Velocity = DIRECTION_VECTOR[Direction.LEFT]
						DashAnim = "DashHoriz"
					elseif (Player:GetData().ButtonPressed == 5 and not room:IsMirrorWorld()) or (Player:GetData().ButtonPressed == 4 and room:IsMirrorWorld()) then
						Velocity = DIRECTION_VECTOR[Direction.RIGHT]
						DashAnim = "DashHoriz"
					elseif Player:GetData().ButtonPressed == 6 then
						Velocity = DIRECTION_VECTOR[Direction.UP]
						DashAnim = "DashUp"
					else
						Velocity = DIRECTION_VECTOR[Direction.DOWN]
						DashAnim = "DashDown"
					end
					CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown = ENRAGED_SOUL_COOLDOWN
					local Soul = Isaac.Spawn(3, CustomFamiliars.ENRAGED_SOUL, 0, Player.Position, Velocity * 12, nil)
					Soul.CollisionDamage = 3.5 * (1 + math.sqrt(level:GetStage()))	-- calculacting the Soul's damage
					
					local SoulSprite = Soul:GetSprite()
					
					SoulSprite:Load("gfx/003.214_enragedsoul.anm2", true)
					if (Player:GetData().ButtonPressed == 4 and not room:IsMirrorWorld()) or (Player:GetData().ButtonPressed == 5 and room:IsMirrorWorld()) then SoulSprite.FlipX = true end
					SoulSprite:Play(DashAnim, true)
					sfx:Play(SoundEffect.SOUND_ANIMA_BREAK, 1, 2, false, 1, 0)
					sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A, 1, 2, false, 1, 0)
				end
				
				-- Magic Pen
				if Player:HasCollectible(CustomCollectibles.MAGIC_PEN) and
				(not CustomData.Items.MAGIC_PEN.CreepSpewCooldown or CustomData.Items.MAGIC_PEN.CreepSpewCooldown <= 0) then
					local creepDirection = DIRECTION_VECTOR[Player:GetFireDirection()]:Resized(20)
					for i = 1, 15 do
						local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 4, Player.Position + creepDirection * i, Vector.Zero, Player)
						creep:ToEffect().Timeout = 120
					end
					
					sfx:Play(SoundEffect.SOUND_BLOODSHOOT, 1, 2, false, 1, 0)
					CustomData.Items.MAGIC_PEN.CreepSpewCooldown = MAGICPEN_CREEP_COOLDOWN
				end
				
				-- Angel's Wings
				if Player:HasCollectible(CustomCollectibles.ANGELS_WINGS) and 
				(not CustomData.Items.ANGELS_WINGS.AttackCooldown or CustomData.Items.ANGELS_WINGS.AttackCooldown <= 0) then
					if CustomData.Items.ANGELS_WINGS.NextAttack == 1 then
						local dogmaBaby = Isaac.Spawn(950, 10, 0, Player.Position, Vector.Zero, Player) 
						dogmaBaby:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
						dogmaBaby:AddEntityFlags(EntityFlag.FLAG_CHARM)
					elseif CustomData.Items.ANGELS_WINGS.NextAttack == 2 then
						for _, angle in pairs({-15, 0, 15}) do
							local vector = Vector.FromAngle(DIRECTION_VECTOR[Player:GetFireDirection()]:GetAngleDegrees() + angle):Resized(7.5)
							local TVTear = Player:FireTear(Player.Position, vector, false, true, false, Player, 1)
							TVTear.TearFlags = TearFlags.TEAR_GLOW | TearFlags.TEAR_PIERCING
							TVTear.Scale = 1.5
							TVTear.FallingAcceleration = 0.03
							TVTear.FallingSpeed = -2.25
							sfx:Play(SoundEffect.SOUND_DOGMA_GODHEAD, 1, 2, false, 1, 0)
						end
					else
						local laserAngle = DIRECTION_VECTOR[Player:GetFireDirection()]:GetAngleDegrees()
						local dogmaLaser
						if laserAngle == 0 then
							dogmaLaser = EntityLaser.ShootAngle(3, Player.Position, laserAngle, 16, Vector(13, -29), Player)
							dogmaLaser.DepthOffset = 10
						elseif laserAngle == 90 then
							dogmaLaser = EntityLaser.ShootAngle(3, Player.Position, laserAngle, 16, Vector(0, -29), Player)
							dogmaLaser.DepthOffset = 20
						elseif laserAngle == 180 then
							dogmaLaser = EntityLaser.ShootAngle(3, Player.Position, laserAngle, 16, Vector(-13, -29), Player)
							dogmaLaser.DepthOffset = 10
						else
							dogmaLaser = EntityLaser.ShootAngle(3, Player.Position, laserAngle, 16, Vector(0, -10), Player)
							dogmaLaser.DepthOffset = 0
						end
						dogmaLaser:GetData().IsDogmaLaser = true
						sfx:Play(SoundEffect.SOUND_DOGMA_BRIMSTONE_SHOOT, 1, 2, false, 1, 0)
					end
					
					if CustomData.Items.ANGELS_WINGS.NextAttack < 3 then CustomData.Items.ANGELS_WINGS.NextAttack = CustomData.Items.ANGELS_WINGS.NextAttack + 1 else CustomData.Items.ANGELS_WINGS.NextAttack = 1 end		
					CustomData.Items.ANGELS_WINGS.AttackCooldown = DOGMA_ATTACK_COOLDOWN	
				end
				
				Player:GetData().ButtonState = nil
			end
		else
			Player:GetData().ButtonState = nil
		end
	end
	
	if CustomData then
		if CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown then 
			CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown = CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown - 1
		end
		if CustomData.Items.MAGIC_PEN.CreepSpewCooldown then 
			CustomData.Items.MAGIC_PEN.CreepSpewCooldown = CustomData.Items.MAGIC_PEN.CreepSpewCooldown - 1
		end
		if CustomData.Items.ANGELS_WINGS.AttackCooldown then 
			CustomData.Items.ANGELS_WINGS.AttackCooldown = CustomData.Items.ANGELS_WINGS.AttackCooldown - 1
		end
	
		if Player:HasTrinket(CustomTrinkets.MAGIC_SWORD) or CustomData.Trinkets.BONE_MEAL.Levels > 0 then
			Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE) 
			Player:EvaluateItems() 
		end
	end
	
	if ((Player:GetSprite():IsPlaying("Appear") and Player:GetSprite():IsEventTriggered("FX"))
	-- for Forget Me Now
	or (level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() and room:IsFirstVisit() and room:GetFrameCount() == 30)) 
	and level:GetCurses() ~= 0 and level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH ~= LevelCurse.CURSE_OF_LABYRINTH then
		if Player:HasTrinket(CustomTrinkets.NIGHT_SOIL) and math.random(100) < NIGHT_SOIL_CHANCE  * Player:GetTrinketMultiplier(CustomTrinkets.NIGHT_SOIL) then
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
		if Player:GetFireDirection() ~= Direction.NO_DIRECTION then
			Player:GetData().RejectionUsed = false
			sfx:Play(SoundEffect.SOUND_WHIP, 1, 2, false, 1, 0)
			-- launching the familiars
			local rejectedBabyTear = Isaac.Spawn(2, CustomTearVariants.REJECTED_BABY, 0, Player.Position, DIRECTION_VECTOR[Player:GetFireDirection()] * 12.5, Player):ToTear()
			rejectedBabyTear.TearFlags = TearFlags.TEAR_PIERCING | TearFlags.TEAR_POISON | TearFlags.TEAR_BURSTSPLIT
			rejectedBabyTear.Scale = 1.5
			rejectedBabyTear:GetSprite():Play(Player:GetData().RejectionAnimName)
			rejectedBabyTear.CollisionDamage = Player.Damage * 4 * #Player:GetData().FamiliarsInBelly
			
			if not Player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION, false) then
				Player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_C_SECTION), true)
			end
		end
	end
	
	if Player:HasCollectible(CustomCollectibles.CAT_IN_A_BOX) then
		for _, enemy in pairs(Isaac.FindInRadius(Player.Position, 800, EntityPartition.ENEMY)) do
			if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy(false) and not enemy:IsBoss() then
				if not isInPlayersLineOfSight(enemy, Player) then
					enemy:AddEntityFlags(EntityFlag.FLAG_FREEZE)
					enemy:GetData()['catInBoxFrozen'] = true
				else
					enemy:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
					enemy:GetData()['catInBoxFrozen'] = false
				end
			end
		end
	end
	
	-- handle Lemegeton + Torn Page
	if Input.IsButtonTriggered(Keyboard.KEY_SPACE, Player.ControllerIndex)
	and Player:HasTrinket(CustomTrinkets.TORN_PAGE) and Player:GetActiveItem(0) == CollectibleType.COLLECTIBLE_LEMEGETON
	and Player:GetActiveCharge(0) < 6 then
		if not Player:GetData()['usedLem'] then
			local heartcharges = math.min(6 - Player:GetActiveCharge(0), Player:GetHearts() + Player:GetSoulHearts() - 1)
			Player:SetActiveCharge(Player:GetActiveCharge(0) + heartcharges, 0)
			Player:TakeDamage(heartcharges, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(Player), 0)
		else
			Player:GetData()['usedLem'] = false
		end
	end
	
	-- substitute to MC_PRE_PLAYER_COLLISION for Red King crawlspaces
	local rcs = Isaac.FindByType(6, 334, 0, true, false)
	if #rcs > 0 then
		for _, rc in pairs(rcs) do
			if rc.Position:Distance(Player.Position) < 15 then
				for i, v in pairs(CustomData.Items.RED_KING.redCrawlspacesData) do
					if v.seed == rc.InitSeed then
						Isaac.ExecuteCommand("goto s.boss." .. tostring(v.associatedRoom))
					end
				end
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
	local ho = Options.HUDOffset
	
	if not CustomData then
		DisplayErrorMessage()
	else
		-- rendering Book of Leavithan's giantbook anim
		if animLength then
			if animLength > 0 then
				if (game:GetFrameCount() % 2 == 0) then
					LeviathanGiantBookAnim:Update()
					animLength = animLength - 1
				end
				for i = 0, 6 do
					LeviathanGiantBookAnim:RenderLayer(i, GetScreenCenterPosition(), Vector.Zero, Vector.Zero)
				end
			elseif animLength == 0 and fakeBerkanoCall then
				fakeBerkanoCall = false
			end
		end
		
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
			
			if player:HasTrinket(CustomTrinkets.GREEDS_HEART) and not isInGhostForm(player) then
				if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= LevelCurse.CURSE_OF_THE_UNKNOWN then
					CoinHeartSprite:SetFrame(CustomData.Trinkets.GREEDS_HEART, 0)	-- custom data value is either "CoinHeartEmpty" or "CoinHeartFull"
				else
					CoinHeartSprite:SetFrame("CoinHeartUnknown", 0)
				end
				CoinHeartSprite:Render(HeartRenderPos + HUDValueRenderOffset * ho, Vector.Zero, Vector.Zero)
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
						DNAPillIcon:SetFrame("pill_" .. tostring(pickupPill.SubType), 0)
						DNAPillIcon:Render(Isaac.WorldToScreen(pickupPill.Position + Vector(15, -15)), Vector.Zero, Vector.Zero)
					end
				end
			end
			
			if player:HasCollectible(CustomCollectibles.RED_MAP) then
				RedMapIcon:SetFrame("RedMap", 0)
				RedMapIcon:Render(MapRenderPos + HUDValueRenderOffset * ho, Vector.Zero, Vector.Zero)
			end
			
			if player:HasCollectible(CustomCollectibles.ENRAGED_SOUL) and CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown
			and CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown <= 0 and CustomData.Items.ENRAGED_SOUL.SoulLaunchCooldown >= -40 then
				SoulIcon:Update()
				SoulIcon:Render(Isaac.WorldToScreen(player.Position + Vector(25, -45)), Vector.Zero, Vector.Zero)
			end
			
			if player:HasCollectible(CustomCollectibles.MAGIC_PEN) and CustomData.Items.MAGIC_PEN.CreepSpewCooldown
			and CustomData.Items.MAGIC_PEN.CreepSpewCooldown <= 0 and CustomData.Items.MAGIC_PEN.CreepSpewCooldown >= -34 then
				PenIcon:Update()
				PenIcon:Render(Isaac.WorldToScreen(player.Position + Vector(25, -45)), Vector.Zero, Vector.Zero)
			end
			
			if player:HasCollectible(CustomCollectibles.ANGELS_WINGS) 
			and CustomData.Items.ANGELS_WINGS.AttackCooldown then
				local DogmaAttackIcon
				
				if CustomData.Items.ANGELS_WINGS.AttackCooldown == 0 then
					DogmaAttackIcon = Sprite()
					DogmaAttackIcon:Load("gfx/ui/ui_visual_clues.anm2", true)
					DogmaAttackIcon:Play("DogmaReady")
					DogmaAttackIcon.PlaybackSpeed = 0.5
				end
				
				if CustomData.Items.ANGELS_WINGS.AttackCooldown <= 0 
				and CustomData.Items.ANGELS_WINGS.AttackCooldown >= -42 then
					DogmaAttackIcon:Update()
					DogmaAttackIcon:Render(Isaac.WorldToScreen(player.Position + Vector(25, -45)), Vector.Zero, Vector.Zero)
				end
			end
			
			if player:GetActiveItem(0) == CustomCollectibles.VAULT_OF_HAVOC then
				Isaac.RenderScaledText('x' .. tostring(math.min(12, #CustomData.Items.VAULT_OF_HAVOC.EnemyList)), 21 + 12 * ho, 23 + 20 * ho, 0.85, 0.85, 0.8, 0.7, 0.7, 1) 
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_RENDER, rplus.OnGameRender)


						-- MC_PRE_USE_ITEM --											
						---------------------				
function rplus:PreUseItem(ItemUsed, RNG, Player, UseFlags, ActiveSlot, CustomVarData)
	if Player:HasTrinket(CustomTrinkets.TORN_PAGE) then
		-- Book of Revelations doesn't cause harbingers to spawn
		if ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS then
			Player:AddSoulHearts(2)
			Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
			return true
			
		-- Book of Sin has a small chance to spawn an item or a chest instead of a pickup
		elseif ItemUsed == CollectibleType.COLLECTIBLE_BOOK_OF_SIN then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			if roll < 1 then
				Isaac.Spawn(5, 100, 0, Isaac.GetFreeNearPosition(Player.Position, 10), Vector.Zero, nil)
			elseif roll < 2 then
				Isaac.Spawn(5, PickupVariant.PICKUP_CHEST, 0, Isaac.GetFreeNearPosition(Player.Position, 10), Vector.Zero, nil)
			elseif roll < 3 then
				Isaac.Spawn(5, PickupVariant.PICKUP_LOCKEDCHEST, 0, Isaac.GetFreeNearPosition(Player.Position, 10), Vector.Zero, nil)
			end
			
			if roll < 3 then
				Player:AnimateCollectible(ItemUsed, "UseItem", "PlayerPickupSparkle")
				return true
			end
			
		-- Anarchist Cookbook spawns a golden troll bomb instead
		elseif ItemUsed == CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK then
			Isaac.Spawn(5, 40, 6, game:GetRoom():GetRandomPosition(20), Vector.Zero, Player)
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
			Source:AddFear(EntityRef(Player), 60)
		end
		
		if Player:HasTrinket(CustomTrinkets.GREEDS_HEART) and CustomData.Trinkets.GREEDS_HEART == "CoinHeartFull"
		and not isInGhostForm(Player) and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isSelfDamage(Flags, "greedsheart") then
			sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 2, false, 1, 0)
			CustomData.Trinkets.GREEDS_HEART = "CoinHeartEmpty"
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
			or freezePreventChecker == 1000
			
			if freezePreventChecker < 1000 then
				Player:RemoveCollectible(ID, true, -1, true)
			else 
				return true
			end
			
			newID = GetUnlockedVanillaCollectible(true, false)
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
		
		if Player:HasTrinket(CustomTrinkets.KEY_KNIFE) then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			if roll < DARK_ARTS_CHANCE * Player:GetTrinketMultiplier(CustomTrinkets.KEY_KNIFE) then
				Player:UseActiveItem(CollectibleType.COLLECTIBLE_DARK_ARTS, UseFlag.USE_NOANIM, -1)
			end
		end
		
		if Player:GetData()['usedCursedCard'] and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isSelfDamage(Flags) then 
			Player:AddBrokenHearts(1)
			Player:GetData()['getBrokenHearts'] = Player:GetData()['getBrokenHearts'] + 1
			sfx:Play(SoundEffect.SOUND_DEVIL_CARD)
			Player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
			Player:EvaluateItems()
			Player:SetMinDamageCooldown(40)
			if Player:GetBrokenHearts() >= 12 then
				Player:Die()
			end
			
			return false
		end
		
		if Player:GetData()['prideStatBoosts'] and Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isSelfDamage(Flags) then
			Player:GetData()['prideStatBoosts'] = false
			Player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_RANGE)
			Player:EvaluateItems()
		end
		
		if Player:HasCollectible(CustomCollectibles.HANDICAPPED_PLACARD) then
			Player:GetData()['areaMult'] = Player:GetData()['areaMult'] and Player:GetData()['areaMult'] + 0.1 or 0.1
		end
		
		-- Tainted hearts
		if Flags & DamageFlag.DAMAGE_FAKE ~= DamageFlag.DAMAGE_FAKE 
		and not isSelfDamage(Flags, "taintedhearts") then
			if Amount == 2 or Player:GetSoulHearts() % 2 == 1 or (Player:GetSoulHearts() == 0 and Player:GetHearts() % 2 == 1) then
				if CustomData.TaintedHearts.EMPTY > 0 then
					CustomData.TaintedHearts.EMPTY = CustomData.TaintedHearts.EMPTY - 1
				end
				if Player:GetGoldenHearts() == 0 then 
					if CustomData.TaintedHearts.DAUNTLESS.Num > 0  then
						CustomData.TaintedHearts.DAUNTLESS.Num = CustomData.TaintedHearts.DAUNTLESS.Num - 1
					elseif CustomData.TaintedHearts.SOILED > 0 then
						CustomData.TaintedHearts.SOILED = CustomData.TaintedHearts.SOILED - 1
					elseif CustomData.TaintedHearts.ZEALOT > 0 then
						CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT - 1
					end
				end
			end 
		end
		
	-- damage inflicted to enemies
	elseif Entity:IsVulnerableEnemy() then
		if Source and Source.Type == 1000 and Source.Variant == EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL and Source.SubType == 4 then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 150
			
			if roll < 0.5 then
				Entity:AddBurn(EntityRef(Entity), 90, 3.5)
			elseif roll < 1 then
				Entity:AddCharmed(EntityRef(Entity), 90)
			elseif roll < 1.5 then
				Entity:AddConfusion(EntityRef(Entity), 90, true)
			elseif roll < 2 then
				Entity:AddFear(EntityRef(Entity), 90)
			elseif roll < 2.5 then
				Entity:AddFreeze(EntityRef(Entity), 60)
			elseif roll < 3 then
				Entity:AddPoison(EntityRef(Entity), 90, 3.5)
			elseif roll < 3.5 then
				Entity:AddShrink(EntityRef(Entity), 60)
			elseif roll < 4 then
				Entity:AddBurn(EntityRef(Entity), 90, 0.5, Color(1, 1, 1, 1, 0, 0, 0))
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
			table.insert(CustomData.ErasedEnemies, Entity.Type)
		end
		
		if CustomData.Items.BLACK_DOLL.ABSepNumber then
			for i = 1, #CustomData.Items.BLACK_DOLL.EntitiesGroupA do 
				if Entity.InitSeed == CustomData.Items.BLACK_DOLL.EntitiesGroupA[i].InitSeed and CustomData.Items.BLACK_DOLL.EntitiesGroupB[i] and Source and Source.Type < 9 then 
					CustomData.Items.BLACK_DOLL.EntitiesGroupB[i]:TakeDamage(Amount * 0.6, 0, EntityRef(Entity), 0)
				end 
			end
			for i = 1, #CustomData.Items.BLACK_DOLL.EntitiesGroupB do 
				if Entity.InitSeed == CustomData.Items.BLACK_DOLL.EntitiesGroupB[i].InitSeed and CustomData.Items.BLACK_DOLL.EntitiesGroupA[i] and Source and Source.Type < 9 then 
					CustomData.Items.BLACK_DOLL.EntitiesGroupA[i]:TakeDamage(Amount * 0.6, 0, EntityRef(Entity), 0)
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
		
		if Entity:GetData()['catInBoxFrozen'] then return false end
	end
end
rplus:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, rplus.EntityTakeDmg)


						-- MC_POST_NPC_INIT --											
						-----------------------
function rplus:OnNPCInit(NPC)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player:HasTrinket(CustomTrinkets.BABY_SHOES) then
			NPC.Size = NPC.Size * (1 - 0.1 * player:GetTrinketMultiplier(CustomTrinkets.BABY_SHOES))
			NPC.Scale = NPC.Scale * (1 - 0.1 * player:GetTrinketMultiplier(CustomTrinkets.BABY_SHOES))
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
		
		if player:HasTrinket(CustomTrinkets.KEY_TO_THE_HEART) 
		and math.random(100) <= HEARTKEY_CHANCE * player:GetTrinketMultiplier(CustomTrinkets.KEY_TO_THE_HEART) 
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
	
		if player:GetTrinketMultiplier(CustomTrinkets.GREEDS_HEART) > 1 and CustomData.Trinkets.GREEDS_HEART == "CoinHeartEmpty" 
		and math.random(100) <= 15 then
			Isaac.Spawn(5, 20, 1, NPC.Position, Vector.FromAngle(math.random(360)), player)
		end
		
		if player:HasCollectible(CustomCollectibles.VAULT_OF_HAVOC) and not CustomData.Items.VAULT_OF_HAVOC.Data 
		and NPC.MaxHitPoints >= 10 and NPC:IsEnemy() and not NPC:IsBoss() then
			table.insert(CustomData.Items.VAULT_OF_HAVOC.EnemyList, NPC)
		end
	
		-- killing sins has a chance to spawn its Jewel
		if NPC.Type >= EntityType.ENTITY_SLOTH and NPC.Type <= EntityType.ENTITY_PRIDE then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			local trueChance = JEWEL_DROP_CHANCE * (NPC.Variant + 1) * (player:HasCollectible(CustomCollectibles.PURE_SOUL) and 21 or 1)
			
			if roll < trueChance then
				if NPC.Type == EntityType.ENTITY_GREED then
					Isaac.Spawn(5, 300, CustomConsumables.CROWN_OF_GREED, NPC.Position, Vector.Zero, nil)
				elseif NPC.Type == EntityType.ENTITY_LUST then
					Isaac.Spawn(5, 300, CustomConsumables.FLOWER_OF_LUST, NPC.Position, Vector.Zero, nil)
				elseif NPC.Type == EntityType.ENTITY_SLOTH then
					Isaac.Spawn(5, 300, CustomConsumables.ACID_OF_SLOTH, NPC.Position, Vector.Zero, nil)
				elseif NPC.Type == EntityType.ENTITY_GLUTTONY then
					Isaac.Spawn(5, 300, CustomConsumables.VOID_OF_GLUTTONY, NPC.Position, Vector.Zero, nil)
				elseif NPC.Type == EntityType.ENTITY_PRIDE then
					Isaac.Spawn(5, 300, CustomConsumables.APPLE_OF_PRIDE, NPC.Position, Vector.Zero, nil)
				elseif NPC.Type == EntityType.ENTITY_WRATH then
					Isaac.Spawn(5, 300, CustomConsumables.CANINE_OF_WRATH, NPC.Position, Vector.Zero, nil)
				elseif NPC.Type == EntityType.ENTITY_ENVY and NPC.Variant == 0 then
					Isaac.Spawn(5, 300, CustomConsumables.MASK_OF_ENVY, NPC.Position, Vector.Zero, nil)
				end
			end
		end
		
		if CustomData.TaintedHearts.DAUNTLESS.Num > 0 then 
			local hearts
			local halfheart
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			if player:GetSoulHearts() > 0 then 
				hearts = (player:GetMaxHearts() + player:GetSoulHearts())
				halfheart = HeartSubType.HEART_HALF_SOUL
			else 
				hearts = player:GetHearts() 
				halfheart = HeartSubType.HEART_HALF
			end 
			if hearts % 2 == 1 and roll <= 20 and CustomData.TaintedHearts.DAUNTLESS.Data == true then 
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, halfheart, NPC.Position, Vector.FromAngle(math.random(360)) * 10, nil)
				CustomData.TaintedHearts.DAUNTLESS.Data = false
			end  
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, rplus.OnNPCDeath)


						-- MC_POST_NPC_RENDER --											
						------------------------
function rplus:OnNPCRender(NPC, _)
	if type(NPC:GetData().IsCrippled) == 'boolean' and NPC:GetData().IsCrippled == true then
		
		NPC.Friction = 90 / (90 + game:GetFrameCount() - NPC:GetData().CrippleStartFrame)
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
			
			-- handle custom cripple deaths
			if NPC:GetData().dropSoulHeart then
				Isaac.Spawn(5, 10, HeartSubType.HEART_HALF_SOUL, NPC.Position, Vector.Zero, nil)
			elseif NPC:GetData().dropRedHeart then
				Isaac.Spawn(5, 10, HeartSubType.HEART_HALF, NPC.Position, Vector.Zero, nil)
			elseif NPC:GetData().dropPickup then
				Isaac.Spawn(5, NPC:GetData().dropPickup, 0, NPC.Position, Vector.Zero, nil)
			elseif NPC:GetData().spawnBoneOrbital then
				Isaac.Spawn(3, FamiliarVariant.BONE_ORBITAL, 0, NPC.Position, Vector.Zero, nil)
			end
			
			NPC:GetData().CrippleDeathBurst = true
		end
	end
	
	if NPC:GetData()['catInBoxFrozen'] == true then
		LineOfSightEyes:SetFrame("EyesClosed", 0)
		LineOfSightEyes:Render(Isaac.WorldToScreen(NPC.Position + Vector(0, -40)), Vector.Zero, Vector.Zero)
	elseif NPC:GetData()['catInBoxFrozen'] == false then
		LineOfSightEyes:SetFrame("EyesOpen", 0)
		LineOfSightEyes:Render(Isaac.WorldToScreen(NPC.Position + Vector(0, -40)), Vector.Zero, Vector.Zero)
	end
	
	if NPC:GetData().isSpawningCreep and game:GetFrameCount() % 12 == 0 then
		local creep = Isaac.Spawn(1000, EffectVariant.CREEP_GREEN, 0, NPC.Position, Vector.Zero, NPC):ToEffect()
		creep.Timeout = 120
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, rplus.OnNPCRender)


						-- MC_POST_PICKUP_INIT -- 										
						-------------------------
function rplus:OnPickupInit(Pickup)	
	local room = game:GetRoom()
	local level = game:GetLevel()
	local stage = level:GetStage()
		
	if (Pickup:GetSprite():IsPlaying("Appear") or Pickup:GetSprite():IsPlaying("AppearFast")) 
	and Pickup:GetSprite():GetFrame() == 0 then
		-- handle Flesh chest replacement
		if math.random(100) <= FLESHCHEST_REPLACE_CHANCE 
		and (Pickup.Variant == PickupVariant.PICKUP_SPIKEDCHEST or Pickup.Variant == PickupVariant.PICKUP_MIMICCHEST) 
		and room:GetType() ~= RoomType.ROOM_CHALLENGE 
		-- make sure there are no players nearby to prevent mimic chests turning into Flesh chests when approached
		and #Isaac.FindInRadius(Pickup.Position, 60, EntityPartition.PLAYER) == 0  then
			Pickup:Morph(5, CustomPickups.FLESH_CHEST, 0, true, true, false)
			sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
		end
		
		-- removing pickups that spawn near Red Crawlspaces (presumably by it being bombed)
		for _, rc in pairs(Isaac.FindByType(6, 334, -1, false, false)) do
			if rc.Position:Distance(Pickup.Position) < 5 and Pickup.Variant ~= 100 then
				Pickup:Remove()
			end
		end
	
		for i = 0, game:GetNumPlayers() - 1 do
			local player = Isaac.GetPlayer(i)
	
			if player:HasTrinket(CustomTrinkets.BASEMENT_KEY) and Pickup.Variant == PickupVariant.PICKUP_LOCKEDCHEST 
			and math.random(100) <= BASEMENTKEY_CHANCE * player:GetTrinketMultiplier(CustomTrinkets.BASEMENT_KEY) then
				Pickup:Morph(5, PickupVariant.PICKUP_OLDCHEST, 0, true, true, false)
			end
			
			if Pickup.Variant == 20 and Pickup.SubType ~= 7 and player:HasTrinket(CustomTrinkets.SLEIGHT_OF_HAND) 
			and math.random(100) <= SLEIGHTOFHAND_UPGRADE_CHANCE * player:GetTrinketMultiplier(CustomTrinkets.SLEIGHT_OF_HAND) then
				local CoinSubTypesByVal = {1, 4, 6, 2, 3, 5, 7} -- penny, doublepack, sticky nickel, nickel, dime, lucky penny, golden penny
				sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 2, false, 1, 0)
				for i = 1, #CoinSubTypesByVal do
					if CoinSubTypesByVal[i] == Pickup.SubType then CurType = i break end
				end
				Pickup:Morph(5, 20, CoinSubTypesByVal[CurType + 1], true, true, false)
			end
			
			-- TAINTED HEARTS REPLACEMENT --
			if Pickup.Variant == 10 and not noCustomHearts and room:GetType() ~= RoomType.ROOM_BOSS then
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomFloat() * 1000
				local capriciousRoll = RNGobj:RandomFloat() * 1000
				local st = Pickup.SubType
				local baseChanceChanged = false
				
				if st == HeartSubType.HEART_FULL or st == HeartSubType.HEART_HALF then
					local baseChance = 5
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
				
					-- 0.5% broken heart
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_BROKEN, true, true, false)
					-- 0.5% enigma heart
					elseif roll < baseChance * 2 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_ENIGMA, true, true, false)
					-- 0.75% curdled heart
					elseif roll < baseChance * 3.5 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_CURDLED, true, true, false)
					-- 1.25% savage heart
					elseif roll < baseChance * 6 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_SAVAGE, true, true, false) end
				elseif st == HeartSubType.HEART_SOUL then
					local baseChance = 125
					if player:HasCollectible(CollectibleType.COLLECTIBLE_RELIC) or
					player:HasCollectible(CollectibleType.COLLECTIBLE_MITRE) or
					player:HasCollectible(CollectibleType.COLLECTIBLE_GIMPY) then
					baseChance = 50 baseChanceChanged = true end
					
					if stage == 1 then
						-- 2.5% zealot heart
						if roll < baseChance * 0.2 and game:GetNumPlayers() == 1 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_ZEALOT, true, true, false) end
					else
						-- 12.5% fettered heart
						if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_FETTERED, true, true, false)
						-- 2.5% zealot heart
						elseif roll < baseChance * 1.2 and game:GetNumPlayers() == 1 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_ZEALOT, true, true, false) end
					end
				elseif st == HeartSubType.HEART_ETERNAL then
					
				elseif st == HeartSubType.HEART_DOUBLEPACK then
					local baseChance = 250
					if player:HasCollectible(CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE) then
					baseChance = 50 baseChanceChanged = true end
					
					-- 25% hoarded heart
					if roll < baseChance then 
						if not CustomData.TaintedHearts.HEARTFLAG_NO_HOARDED_REROLL then
							Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_HOARDED, true, true, false)
						else
							CustomData.TaintedHearts.HEARTFLAG_NO_HOARDED_REROLL = false
						end
					end
				elseif st == HeartSubType.HEART_BLACK then
					local baseChance = 200
					if player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_BUM) or
					player:HasTrinket(TrinketType.TRINKET_BLACK_LIPSTICK) or
					player:HasTrinket(TrinketType.TRINKET_DAEMONS_TAIL) then
					baseChance = 50 baseChanceChanged = true end
				
					-- 20% deserted heart
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_DESERTED, true, true, false)
					-- 20% benighted heart
					elseif roll < baseChance * 2 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_BENIGHTED, true, true, false) end
				elseif st == HeartSubType.HEART_GOLDEN then
					
				elseif st == HeartSubType.HEART_HALF_SOUL then
					
				elseif st == HeartSubType.HEART_SCARED then
					
				elseif st == HeartSubType.HEART_BLENDED then
					local baseChance = 300
					
					-- 30% deserted heart
					if roll < baseChance then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_DESERTED, true, true, false) end
				elseif st == HeartSubType.HEART_BONE then
				
				elseif st == HeartSubType.HEART_ROTTEN then
					local baseChance = 75
					
					-- 7.5% empty heart
					if roll < baseChance and game:GetNumPlayers() == 1 then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_EMPTY, true, true, false) end
				end
				
				-- 0.75% capricious heart
				local baseChance = 7.5
				if baseChanceChanged then baseChance = 1.25 end
				
				if capriciousRoll < baseChance
				then Pickup:Morph(5, 10, CustomPickups.TaintedHearts.HEART_CAPRICIOUS, true, true, false) end
			end
		end
	end
	
	if (Pickup.Variant == CustomPickups.FLESH_CHEST or Pickup.Variant == CustomPickups.BLACK_CHEST 
	or Pickup.Variant == CustomPickups.SCARLET_CHEST or Pickup.Variant == CustomPickups.COFFIN)
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
	local sp = Pickup:GetSprite()
	
	if player:HasCollectible(CustomCollectibles.TWO_PLUS_ONE)
	and Pickup.Price > -6 and Pickup.Price ~= 0 		-- this pickup costs something
	and not player:IsHoldingItem()						-- we're not holding another pickup right now
	then
		-- this monstrosity is able to detect whether we really buy something and whether we don't
		if (Pickup.Price == -1 and player:GetMaxHearts() >= 2)
		or (Pickup.Price == -2 and player:GetMaxHearts() >= 4)
		or (Pickup.Price == -3 and player:GetSoulHearts() >= 6)
		or (Pickup.Price == -4 and player:GetMaxHearts() >= 2 and player:GetSoulHearts() >= 4)	-- this devil deal is affordable
		then
			CustomData.Items.TWO_PLUS_ONE.ItemsBought_HEARTS = CustomData.Items.TWO_PLUS_ONE.ItemsBought_HEARTS + 1
		elseif Pickup.Price > 0 and player:GetNumCoins() >= Pickup.Price						-- this shop item is affordable
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
	
	if player:HasTrinket(CustomTrinkets.GREEDS_HEART) and CustomData.Trinkets.GREEDS_HEART == "CoinHeartEmpty" and Pickup.Variant == 20 and Pickup.SubType ~= 6 
	and not isInGhostForm(player) 
	-- if the player's Keeper, they should be at full health to gain a new coin heart
	and (player:GetHearts() == player:GetMaxHearts() or (player:GetPlayerType() ~= 14 and player:GetPlayerType() ~= 33)) then
		player:AddCoins(-1)
		CustomData.Trinkets.GREEDS_HEART = "CoinHeartFull"
	end
	
	if Pickup.Variant == 10 and player:CanPickRedHearts()
	and (Pickup.SubType == 1 or Pickup.SubType == 2 or Pickup.SubType == 5 
	or Pickup.SubType == HeartSubType.HEART_SCARED or Pickup.SubType == CustomPickups.TaintedHearts.HEART_HOARDED) then
		-- different hearts gives different boosts
		local mult = 2
		if Pickup.SubType == 2 then mult = 1
		elseif Pickup.SubType == 5 then mult = 4
		elseif Pickup.SubType == CustomPickups.TaintedHearts.HEART_HOARDED then mult = 8 end
		
		-- bonuses should apply according to how many hearts were FILLED, not how many were picked up
		mult = math.min(mult, player:GetEffectiveMaxHearts() - player:GetHearts())
	
		if ((game:GetFrameCount() - CustomData.Pills.YUCK.UseFrame) <= 900 and player:GetData()['usedYuck'])
		or ((game:GetFrameCount() - CustomData.Pills.YUCK.UseFrame) <= 1800 and player:GetData()['usedHorseYuck']) then
			for i = 1, mult do 
				Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector.Zero, nil) 
			end
		else
			player:GetData()['usedHorseYuck'] = false
			player:GetData()['usedYuck'] = false
		end
		
		if ((game:GetFrameCount() - CustomData.Pills.YUM.UseFrame) <= 900 and player:GetData()['usedYum'])
		or ((game:GetFrameCount() - CustomData.Pills.YUM.UseFrame) <= 1800 and player:GetData()['usedHorseYum']) then
			for n = 1, mult do
				RNGobj:SetSeed(Random() + 1, 1)
				local YumStat = RNGobj:RandomInt(4) + 1
				
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
			end
			
			player:EvaluateItems()
		else
			player:GetData()['usedHorseYum'] = false
			player:GetData()['usedYum'] = false
		end
	end
	
	if Pickup.Variant == CustomPickups.FLESH_CHEST and Pickup.SubType == 0 then
		if player:GetDamageCooldown() > 0 then return false end
		
		player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(Pickup), 30)
		CustomData.FleshChestConsumedHP = CustomData.FleshChestConsumedHP + 1
		sp:Play("TakeHealth")
		
		if ((CustomData.FleshChestConsumedHP > 2 and math.random(100) < FLESHCHEST_OPEN_CHANCE) or CustomData.FleshChestConsumedHP == 6) then
			CustomData.FleshChestConsumedHP = 0
			-- subtype 1: opened chest (need to remove)
			Pickup.SubType = 1
			-- setting some data for pickup, because it is deleted on entering a new room, and the pickup is removed as well
			Pickup:GetData()["IsInRoom"] = true
			sp:Play("Open")
			sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
			RNGobj:SetSeed(Random() + 1, 1)
			local DieRoll = RNGobj:RandomFloat() * 100
			
			if DieRoll < 30 then
				local newID = GetUnlockedCollectibleFromCustomPool(CustomItempools.FLESH_CHEST)
				local fleshChest = Isaac.Spawn(5, 100, newID, Pickup.Position, Vector(0, 0), Pickup)
				fleshChest:GetSprite():ReplaceSpritesheet(5, "gfx/items/fleshchest_itemaltar.png") 
				fleshChest:GetSprite():LoadGraphics()
				
				Pickup:Remove()
			else
				RNGobj:SetSeed(Pickup.DropSeed, 1)
				local NumOfPickups = RNGobj:RandomInt(4) + 4 -- 4 to 7 pickups
				
				for i = 1, NumOfPickups do
					local variant = nil
					local subtype = nil
					
					if math.random(100) < 60 then
						local heartSubTypes = {1, 2, 9, 11, 12}
						variant = 10
						subtype = heartSubTypes[math.random(#heartSubTypes)]
					else
						variant = 70
						subtype = 0
					end
					Isaac.Spawn(5, variant, subtype, Pickup.Position, Vector.FromAngle(math.random(360)) * 4, Pickup)
				end
				
				local t = GetUnlockedTrinketFromCustomPool(CustomItempools.FLESHCHEST_trinkets)
				if t then Isaac.Spawn(5, 350, t, Pickup.Position, Vector.FromAngle(math.random(360)) * 4, Pickup) end
			end
		end
	end
	
	if Pickup.Variant == CustomPickups.BLACK_CHEST and Pickup.SubType == 0 then		
		-- setting some data for pickup, because it is deleted on entering a new room, and the pickup is removed as well
		Pickup:GetData()["IsInRoom"] = true
		sp:Play("Open")
		sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
		player:TakeDamage(1, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(Pickup), 24)
		RNGobj:SetSeed(Random() + 1, 1)
		local DieRoll = RNGobj:RandomFloat() * 100
		
		if DieRoll < 10 then
			local BlackChestPedestal = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_CURSE, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), Pickup.Position, Vector(0, 0), Pickup)
			BlackChestPedestal:GetSprite():ReplaceSpritesheet(5,"gfx/items/blackchest_itemaltar.png") 
			BlackChestPedestal:GetSprite():LoadGraphics()
			
			Pickup:Remove()
		elseif DieRoll < 70 then
			-- subtype 2: opened chest with consumables (need to close again later)
			Pickup.SubType = 2
			Pickup:GetData()['OpenFrame'] = game:GetFrameCount()
			
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			for i, v in pairs(DropTables.BLACK_CHEST) do
				if roll < DropTables.BLACK_CHEST[i][1] then
					for x, y in pairs(DropTables.BLACK_CHEST[i][2]) do
						Isaac.Spawn(5, y[1], y[2], Pickup.Position, Vector.FromAngle(math.random(360)) * 3, player)
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
		if not canOpenScarletChests(player) or sp:IsPlaying("Appear") then return false end
		
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
	
	-- TAINTED HEARTS
	if Pickup.Variant == 10 and Pickup.SubType >= CustomPickups.TaintedHearts.HEART_BROKEN and Pickup.SubType <= CustomPickups.TaintedHearts.HEART_DESERTED 
	and Pickup.Price == 0 and not sp:IsPlaying("Collect") then
		local hasBow = player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) and 2 or 1
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_BROKEN then
			player:AddMaxHearts(2)
			player:AddHearts(2)
			player:AddBrokenHearts(1)
			sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_DAUNTLESS then
			if getRightMostHeartForRender(player) - player:GetGoldenHearts() - CustomData.TaintedHearts.ZEALOT - CustomData.TaintedHearts.SOILED > CustomData.TaintedHearts.DAUNTLESS.Num and not isInGhostForm(player) then
				CustomData.TaintedHearts.DAUNTLESS.Num = CustomData.TaintedHearts.DAUNTLESS.Num + 1
				sfx:Play(SoundEffect.SOUND_DIVINE_INTERVENTION, 1, 2, false, 1, 0)
				sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_HOARDED then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_BUM) then
				sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
				for i = 1, 2 do
					CustomData.TaintedHearts.HEARTFLAG_NO_HOARDED_REROLL = true
					Isaac.Spawn(5, 10, HeartSubType.HEART_DOUBLEPACK, Pickup.Position, Vector.FromAngle(math.random(360)) * 3, player)
				end
			elseif player:CanPickRedHearts() then
				player:AddHearts(8 * hasBow)
				sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_SOILED then
			if getRightMostHeartForRender(player) - player:GetGoldenHearts()  - CustomData.TaintedHearts.DAUNTLESS.Num - CustomData.TaintedHearts.ZEALOT > CustomData.TaintedHearts.SOILED and not isInGhostForm(player) then
				CustomData.TaintedHearts.SOILED = CustomData.TaintedHearts.SOILED + 1
				sfx:Play(SoundEffect.SOUND_POOPITEM_STORE, 1, 2, false, 1, 0)
				sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_CURDLED then
			if player:CanPickRedHearts() then
				player:AddHearts(2 * hasBow)
				sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 2, false, 1, 0)
				Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, 0, player.Position, Vector.Zero, player)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_SAVAGE then
			if player:CanPickRedHearts() then
				player:AddHearts(2 * hasBow)
				sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
				addTemporaryDmgBoost(player)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_BENIGHTED then
			if player:CanPickBlackHearts() then
				player:AddBlackHearts(2)
				-- Tainted Forgotten is shit, yay
				if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
					for i = 0, game:GetNumPlayers() - 1 do
						if Isaac.GetPlayer(i):GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then player = Isaac.GetPlayer(p) end
					end
				end
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
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_EMPTY then
			if getRightMostHeartForRender(player) > CustomData.TaintedHearts.EMPTY and not isInGhostForm(player) then
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
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_ZEALOT then
			if getRightMostHeartForRender(player) - player:GetGoldenHearts()  - CustomData.TaintedHearts.DAUNTLESS.Num -CustomData.TaintedHearts.SOILED > CustomData.TaintedHearts.ZEALOT and not isInGhostForm(player) then
				CustomData.TaintedHearts.ZEALOT = CustomData.TaintedHearts.ZEALOT + 1
				sfx:Play(SoundEffect.SOUND_HOLY, 1, 2, false, 1, 0)
			else return false end
		end
		
		if Pickup.SubType == CustomPickups.TaintedHearts.HEART_DESERTED then
			if not (player:CanPickRedHearts() or player:CanPickBlackHearts()) then return false end
			if player:CanPickRedHearts() then player:AddHearts(1) sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0) elseif player:CanPickBlackHearts() then player:AddBlackHearts(1) sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0) end
			if player:CanPickRedHearts() then player:AddHearts(1) sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0) elseif player:CanPickBlackHearts() then player:AddBlackHearts(1) sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 2, false, 1, 0) end
		end
		
		sp:Play("Collect")
	end
	
	if player:HasCollectible(CustomCollectibles.STARGAZERS_HAT) 
	and Pickup.Variant == 10 
	and (Pickup.SubType == HeartSubType.HEART_SOUL or Pickup.SubType == HeartSubType.HEART_HALF_SOUL)
	and not (Pickup.Price > 0 and player:GetNumCoins() < Pickup.Price) then
		local HatSlot = 0
		local addCharges = 2
	
		if Pickup.SubType == HeartSubType.HEART_HALF_SOUL then addCharges = 1 end
		if player:GetActiveItem(0) ~= CustomCollectibles.STARGAZERS_HAT then HatSlot = 1 end
		
		if player:GetActiveCharge(HatSlot) < 4 then 
			player:SetActiveCharge(player:GetActiveCharge(HatSlot) + addCharges, HatSlot)
			if player:GetActiveCharge(HatSlot) >= 4 then sfx:Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 2, false, 1, 0) else sfx:Play(SoundEffect.SOUND_BEEP, 1, 2, false, 1, 0) end
			Pickup:Remove()
			return false
		end
	end
	
	if player:HasTrinket(CustomTrinkets.SHATTERED_STONE) 
	and (Pickup.Variant == 20 or Pickup.Variant == 30 or Pickup.Variant == 40) then
		local locustSpawnChance = 0
		RNGobj:SetSeed(Random() + 1, 1)
		local roll = RNGobj:RandomFloat() * 100
		
		if PickupWeights[Pickup.Variant] and PickupWeights[Pickup.Variant][Pickup.SubType] then
			locustSpawnChance = PickupWeights[Pickup.Variant][Pickup.SubType] * 20
		end
		
		if roll < locustSpawnChance + 1 then
			RNGobj:SetSeed(Random() + 1, 1)
			local locustRoll = RNGobj:RandomInt(5) + 1
			Isaac.Spawn(3, FamiliarVariant.BLUE_FLY, locustRoll, player.Position, Vector.Zero, player)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, rplus.PickupCollision)


						-- MC_POST_PICKUP_UPDATE -- 										
						---------------------------
function rplus:PostPickupUpdate(Pickup)
	local sp = Pickup:GetSprite()
	
	-- items spawned by Auction Gavel
	if Pickup.ShopItemId == -321 and Pickup.SpawnerType == 1 and Pickup.Price >= 6 then
		if type(Pickup:GetData().Data) == 'nil' 
		and (not Pickup.SpawnerEntity or (Pickup.SpawnerEntity:ToPlayer():GetPlayerType() ~= PlayerType.PLAYER_ISAAC_B 
		and not Pickup.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER))) then
			Pickup:Remove()
		else
			local pf = Pickup.FrameCount
			
			if pf % 5 == 0 then
				if Pickup:GetData().Data == "normal price" then
					Pickup.Price = math.min(math.random(22 + pf // 24, 32 + pf // 24), 99)
				elseif Pickup:GetData().Data == "sale price" then
					Pickup.Price = math.min(math.random(10 + pf // 27, 20 + pf // 27), 99)
				end
			end
		end
	end
	
	if Pickup.Variant == 10 and Pickup.SubType >= CustomPickups.TaintedHearts.HEART_BROKEN and Pickup.SubType <= CustomPickups.TaintedHearts.HEART_DESERTED then
		if sp:IsPlaying("Collect") then Pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE end
		if sp:IsFinished("Collect") then Pickup:Remove() end
	end
	
	if Pickup.Variant == CustomPickups.BLACK_CHEST then
		if Pickup:GetData()['OpenFrame'] and game:GetFrameCount() >= Pickup:GetData()['OpenFrame'] + 60 then
			sp:Play("Close")
			sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			Pickup.SubType = 0
			Pickup:GetData()['OpenFrame'] = nil
		end
		
		if sp:IsFinished("Close") then sp:Play("Idle") end
	end
	
	if Pickup.Variant == CustomPickups.FLESH_CHEST then
		if sp:IsFinished("TakeHealth") then sp:Play("Idle") end
	end
	
	if Pickup.Variant == CustomPickups.COFFIN then
		if sp:IsFinished("Exploded") then sp:Play("Idle") end
		
		if Pickup.FrameCount == 1 then Pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, rplus.PostPickupUpdate)


						-- MC_POST_FIRE_TEAR --
						-----------------------
function rplus:OnTearFired(Tear)
	local Player
	if Tear.Parent then Player = Tear.Parent:ToPlayer() elseif Tear.SpawnerEntity then Player = Tear.SpawnerEntity:ToPlayer() end
	if not Player then return end
	local tearSprite = Tear:GetSprite()
	
	if Player:HasCollectible(CustomCollectibles.SCALPEL) then 
		Tear.Velocity = -Tear.Velocity
		local tearAngle = DIRECTION_VECTOR[Player:GetFireDirection()]:GetAngleDegrees()
		if tearAngle == 0 then
			Tear.Position = Tear.Position + Vector(-29, 0)
		elseif tearAngle == 90 then
			Tear.Position = Tear.Position + Vector(0, -17)
		elseif tearAngle == 180 then
			Tear.Position = Tear.Position + Vector(29, 0)
		else
			Tear.Position = Tear.Position + Vector(0, 17)
		end
	end
	
	if Player:HasCollectible(CustomCollectibles.CEREMONIAL_BLADE) and math.random(100) <= CEREM_DAGGER_LAUNCH_CHANCE then
		-- launching the dagger
		local BladeTear = Isaac.Spawn(2, CustomTearVariants.CEREMONIAL_BLADE, 0, Player.Position, Tear.Velocity, Player):ToTear()
		BladeTear:AddTearFlags(TearFlags.TEAR_PIERCING) 
		local s = BladeTear:GetSprite()
		s:Play("Move")
		Tear:Update()
	end
	
	if Player:HasCollectible(CustomCollectibles.SINNERS_HEART) then
		Tear:ChangeVariant(CustomTearVariants.SINNERS_HEART)
		tearSprite:Play("Move")
		tearSprite.Scale = Vector(0.5, 0.5)
		Tear:Update()
	end
	
	if Player:HasCollectible(CustomCollectibles.ANGELS_WINGS) then
		Tear:ChangeVariant(CustomTearVariants.DOGMA_FEATHER)
		tearSprite:Play("Move")
		Tear:Update()
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, rplus.OnTearFired)
						

						-- MC_POST_TEAR_UPDATE --
						-------------------------
function rplus:OnTearUpdate(Tear)
	local Player
	if Tear.Parent then Player = Tear.Parent:ToPlayer() elseif Tear.SpawnerEntity then Player = Tear.SpawnerEntity:ToPlayer() end
	if not Player then return end
	local tearSprite = Tear:GetSprite()
	
	if Tear.Variant == 120 or Tear.Variant == 121 or Tear.Variant == 125 then
		tearSprite.Rotation = Tear.Velocity:GetAngleDegrees() + 90
	end
	
	if Tear.Variant == CustomTearVariants.DOGMA_FEATHER and Tear.FrameCount % 3 == 0 then
		Tear.CollisionDamage = Tear.CollisionDamage * 1.02
	end
	
	if Tear.Height >= -5 then
		-- manually making tears leave splashes when they land
		local tearToSplashCol = {
			[CustomTearVariants.CEREMONIAL_BLADE] = Color(0.56, 0.56, 0.56, 1, 0, 0, 0),
			[CustomTearVariants.SINNERS_HEART] = Color(0.93, 0.22, 0.56, 1, 0, 0, 0),
			[CustomTearVariants.REJECTED_BABY] = Color(0.87, 0.24, 0.18, 1, 0, 0, 0),
			[CustomTearVariants.DOGMA_FEATHER] = Color(0.53, 0.51, 0.59, 1, 0, 0, 0)
		}
		
		if tearToSplashCol[Tear.Variant] then
			local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 0, Tear.Position, Vector.Zero, Tear):ToEffect()
			
			splash:SetColor(tearToSplashCol[Tear.Variant], 100, 1, false, false)
			-- remove laser impacts left by Trisagion
			for _, impact in pairs(Isaac.FindByType(1000, 50)) do
				if impact.SpawnerType == 7 then impact:Remove() end
			end
			
			Tear:Remove()
		end
		
		if Tear:GetData()['spawnsGuts'] then
			Isaac.Spawn(EntityType.ENTITY_CYST, 0, 0, Tear.Position, Vector.Zero, nil)
			Tear:Remove()
		end
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
		table.insert(CustomData.ErasedEnemies, Collider.Type)
		Tear:Remove()
	end
	
	if Tear.Variant == CustomTearVariants.VALENTINES_CARD and Collider.Type ~= 951 then
		Collider:AddCharmed(EntityRef(Player), -1)
	end
	
	if Player:HasCollectible(CustomCollectibles.CROSS_OF_CHAOS) and not Collider:GetData().IsCrippled then
		RNGobj:SetSeed(Random() + 1, 1)
		local roll = RNGobj:RandomFloat() * 100
		local trueCrippleChance = math.max(CRIPPLE_TEAR_CHANCE, CRIPPLE_TEAR_CHANCE + Player.Luck / 2)
		trueCrippleChance = math.min(trueCrippleChance, 7)
		
		if roll < trueCrippleChance then
			crippleEnemy(Collider)
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, rplus.TearCollision)


						-- MC_POST_LASER_UPDATE --
						--------------------------
function rplus:OnLaserUpdate(Laser)
	-- replacing the spritesheet of static Dogma laser
	if Laser.FrameCount <= 2 and Laser.SpawnerEntity and Laser.SpawnerEntity:ToPlayer() 
	and Laser:GetData().IsDogmaLaser and Laser.Variant == 3 then
		Laser.CollisionDamage = 3.5
		
		sfx:Stop(SoundEffect.SOUND_BLOOD_LASER)
		Laser:GetSprite():ReplaceSpritesheet(0, "gfx/dogma_laser.png")
		Laser:GetSprite():LoadGraphics()
		
		if Laser.Child then
			Laser.Child:GetSprite():ReplaceSpritesheet(0, "gfx/dogma_laser_end.png")
			Laser.Child:GetSprite():LoadGraphics()
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, rplus.OnLaserUpdate)


						-- MC_EVALUATE_CACHE --							
						-----------------------
function rplus:OnCacheEvaluate(Player, Flag) 
	if not CustomData then return end
	
	-- If any Stat-Changes are done, just check for the collectible in the cacheflag (be sure to set the cacheflag in the items.xml)
	if Flag == CacheFlag.CACHE_DAMAGE then
		-- temporary dmg boosts
		if Player:GetData().flagGiveTempBoost then
			Player.Damage = Player.Damage + CustomStatups.Damage.DMG_TEMPORARY * (Player:GetData().numTempBoosts - Player:GetData().boostTimeStep / 50)
		end
		
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART) then
			Player.Damage = Player.Damage + CustomStatups.Damage.SINNERS_HEART_ADD
			Player.Damage = Player.Damage * CustomStatups.Damage.SINNERS_HEART_MUL
		end
		
		if Player:HasTrinket(CustomTrinkets.MAGIC_SWORD) then
			Player.Damage = Player.Damage * CustomStatups.Damage.MAGIC_SWORD_MUL * Player:GetTrinketMultiplier(CustomTrinkets.MAGIC_SWORD)
		end
		
		if CustomData.Items.CHEESE_GRATER.NumUses then
			if Player:GetData()['graterUsed'] == true then
				Player.Damage = Player.Damage + CustomData.Items.CHEESE_GRATER.NumUses * CustomStatups.Damage.CHEESE_GRATER
			end
		end
		
		if Player:HasCollectible(CustomCollectibles.BLESS_OF_THE_DEAD) and CustomData then
			Player.Damage = Player.Damage + CustomData.Items.BLESS_OF_THE_DEAD.NumUses * CustomStatups.Damage.BLESS_OF_THE_DEAD
		end
		
		if Player:GetData()['GetYumDamage'] then
			Player.Damage = Player.Damage + CustomData.Pills.YUM.NumDamage * CustomStatups.Damage.PILL_YUM
		end
		
		if CustomData.Trinkets.BONE_MEAL.Levels > 0 then
			Player.Damage = Player.Damage * CustomStatups.Damage.BONE_MEAL_MUL ^ (CustomData.Trinkets.BONE_MEAL.Levels)
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.Damage = Player.Damage + CustomStatups.Damage.MOTHERS_LOVE * CustomData.Items.MOTHERS_LOVE.NumStats
		end
		
		if Player:GetData()['usedDemonForm'] then 
			Player.Damage = Player.Damage + CustomData.Cards.DEMON_FORM.NumUses * CustomStatups.Damage.DEMON_FORM
		end
		
		if Player:GetData()['NumPickedBenightedHearts'] then
			Player.Damage = Player.Damage + Player:GetData()['NumPickedBenightedHearts'] * 0.1
		end
		
		if Player:GetData()['prideStatBoosts'] then
			Player.Damage = Player.Damage * CustomStatups.Damage.APPLE_OF_PRIDE_MUL
		end
	end
	
	if Flag == CacheFlag.CACHE_FIREDELAY then
		if Player:HasCollectible(CustomCollectibles.ORDINARY_LIFE) then
			Player.MaxFireDelay = Player.MaxFireDelay * CustomStatups.Tears.ORDINARY_LIFE_MUL
		end
		
		if Player:HasCollectible(CustomCollectibles.GUSTY_BLOOD) then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomStatups.Tears.GUSTY_BLOOD * CustomData.Items.GUSTY_BLOOD.CurrentTears^2 / (CustomData.Items.GUSTY_BLOOD.CurrentTears + 1))
		end
		
		if Player:GetData()['GetYumTears'] then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomData.Pills.YUM.NumTears * CustomStatups.Tears.PILL_YUM)
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomStatups.Tears.MOTHERS_LOVE * CustomData.Items.MOTHERS_LOVE.NumStats)
		end
		
		if Player:GetData()['getBrokenHearts'] and Player:GetData()['getBrokenHearts'] > 0 then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomStatups.Tears.CURSED_CARD * Player:GetData()['getBrokenHearts'])
		end
		
		if Player:GetData()['prideStatBoosts'] then
			Player.MaxFireDelay = Player.MaxFireDelay * CustomStatups.Tears.APPLE_OF_PRIDE_MUL
		end
		
		if Player:GetData()['envyTearsBoost'] and Player:GetData()['envyTearsBoost'] > 0 then
			Player.MaxFireDelay = GetFireDelay(GetTears(Player.MaxFireDelay) + CustomStatups.Tears.MASK_OF_ENVY * Player:GetData()['envyTearsBoost'])
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
			Player.TearFlags = Player.TearFlags | TearFlags.TEAR_PIERCING
		end
	end
	
	if Flag == CacheFlag.CACHE_SHOTSPEED then
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART)  then
			Player.ShotSpeed = Player.ShotSpeed + CustomStatups.ShotSpeed.SINNERS_HEART
		end
		
		if Player:HasCollectible(CustomCollectibles.ANGELS_WINGS)  then
			Player.ShotSpeed = Player.ShotSpeed + CustomStatups.ShotSpeed.ANGELS_WINGS
		end
	end
	
	if Flag == CacheFlag.CACHE_RANGE then 
		-- (((Range currently not functioning, blame Edmund)))
		-- it's working now, yo!
		if Player:HasCollectible(CustomCollectibles.SINNERS_HEART)  then
			Player.TearRange = Player.TearRange + CustomStatups.Range.SINNERS_HEART * 40
		end
		
		if Player:GetData()['GetYumRange'] then
			Player.TearRange = Player.TearRange + CustomData.Pills.YUM.NumRange * CustomStatups.Range.PILL_YUM * 40
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.TearRange = Player.TearRange + CustomStatups.Range.MOTHERS_LOVE * CustomData.Items.MOTHERS_LOVE.NumStats * 40
		end
		
		if Player:GetData()['prideStatBoosts'] then
			Player.TearRange = Player.TearRange + CustomStatups.Range.APPLE_OF_PRIDE * 40
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
		if CustomData.Items.MARK_OF_CAIN == "player revived" then
			Player:CheckFamiliar(CustomFamiliars.ENOCH_B, getTrueFamiliarNum(Player, CustomCollectibles.MARK_OF_CAIN), Player:GetCollectibleRNG(CustomCollectibles.MARK_OF_CAIN))
		else
			Player:CheckFamiliar(CustomFamiliars.ENOCH, getTrueFamiliarNum(Player, CustomCollectibles.MARK_OF_CAIN), Player:GetCollectibleRNG(CustomCollectibles.MARK_OF_CAIN))
		end
		if Player:GetData()['usedSpiritualReserves'] then
			if Player:GetData()['usedSpiritualReserves'][1] then
				Player:CheckFamiliar(CustomFamiliars.SPIRITUAL_RESERVES_MOON, 1, Player:GetCollectibleRNG(1))
			end
			if Player:GetData()['usedSpiritualReserves'][2] then 
				Player:CheckFamiliar(CustomFamiliars.SPIRITUAL_RESERVES_SUN, 1, Player:GetCollectibleRNG(1))
			end
		end
		Player:CheckFamiliar(CustomFamiliars.FRIENDLY_SACK, getTrueFamiliarNum(Player, CustomCollectibles.FRIENDLY_SACK), Player:GetCollectibleRNG(CustomCollectibles.FRIENDLY_SACK))
		if Player:GetData()['UFCLevel'] == 1 or not Player:GetData()['UFCLevel'] then
			Player:CheckFamiliar(CustomFamiliars.ULTRA_FLESH_KID_L1, getTrueFamiliarNum(Player, CustomCollectibles.ULTRA_FLESH_KID), Player:GetCollectibleRNG(CustomCollectibles.ULTRA_FLESH_KID))
		elseif Player:GetData()['UFCLevel'] == 2 then
			Player:CheckFamiliar(CustomFamiliars.ULTRA_FLESH_KID_L2, getTrueFamiliarNum(Player, CustomCollectibles.ULTRA_FLESH_KID), Player:GetCollectibleRNG(CustomCollectibles.ULTRA_FLESH_KID))
		elseif Player:GetData()['UFCLevel'] == 3 then
			Player:CheckFamiliar(CustomFamiliars.ULTRA_FLESH_KID_L3, getTrueFamiliarNum(Player, CustomCollectibles.ULTRA_FLESH_KID), Player:GetCollectibleRNG(CustomCollectibles.ULTRA_FLESH_KID))
		end
		Player:CheckFamiliar(FamiliarVariant.LEECH, getTrueFamiliarNum(Player, CustomCollectibles.ULTRA_FLESH_KID) + getTrueFamiliarNum(Player, CollectibleType.COLLECTIBLE_LEECH), Player:GetCollectibleRNG(CustomCollectibles.ULTRA_FLESH_KID))
	end
	
	if Flag == CacheFlag.CACHE_LUCK then
		if Player:GetData()['usedLoadedDice'] then
			Player.Luck = Player.Luck + CustomStatups.Luck.LOADED_DICE
		end
		
		if Player:GetData()['GetYumLuck'] then
			Player.Luck = Player.Luck + CustomData.Pills.YUM.NumLuck * CustomStatups.Luck.PILL_YUM
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.Luck = Player.Luck + CustomStatups.Luck.MOTHERS_LOVE * CustomData.Items.MOTHERS_LOVE.NumStats
		end
		
		if Player:GetData().JewelData_GREED then
			Player.Luck = Player.Luck - Player:GetData().JewelData_GREED 
		end
		
		if Player:GetData()['prideStatBoosts'] then
			Player.Luck = Player.Luck + CustomStatups.Luck.APPLE_OF_PRIDE
		end
	end
	
	if Flag == CacheFlag.CACHE_SPEED then
		if Player:HasCollectible(CustomCollectibles.GUSTY_BLOOD) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.Speed.GUSTY_BLOOD * CustomData.Items.GUSTY_BLOOD.CurrentSpeed^2 / (CustomData.Items.GUSTY_BLOOD.CurrentSpeed + 1)
		end
		
		if Player:HasCollectible(CustomCollectibles.MOTHERS_LOVE) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.Speed.MOTHERS_LOVE * CustomData.Items.MOTHERS_LOVE.NumStats
		end
		
		if Player:HasCollectible(CustomCollectibles.NERVE_PINCH) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.Speed.NERVE_PINCH * CustomData.Items.NERVE_PINCH.NumTriggers
		end
		
		if Player:HasCollectible(CustomCollectibles.HAND_ME_DOWNS) then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.Speed.HAND_ME_DOWNS
		end
		
		if Player:GetData()['prideStatBoosts'] then
			Player.MoveSpeed = Player.MoveSpeed + CustomStatups.Speed.APPLE_OF_PRIDE
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
rplus:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, rplus.OnCacheEvaluate)


						-- MC_FAMILIAR_INIT --										
						----------------------
function rplus:FamiliarInit(Familiar)
	local fSprite = Familiar:GetSprite()
	
	if Familiar.Variant == CustomFamiliars.BAG_O_TRASH or  Familiar.Variant == CustomFamiliars.CHERUBIM
	or Familiar.Variant == CustomFamiliars.REJECTION_FETUS or Familiar.Variant == CustomFamiliars.ENOCH
	or Familiar.Variant == CustomFamiliars.ENOCH_B or Familiar.Variant == CustomFamiliars.FRIENDLY_SACK then
		Familiar:AddToFollowers()
		Familiar.IsFollower = true
	end
	
	if Familiar.Variant == CustomFamiliars.BAG_O_TRASH then
		CustomData.Items.BAG_O_TRASH.Levels = 1
	end
	
	if Familiar.Variant == CustomFamiliars.TOY_TANK_1 or Familiar.Variant == CustomFamiliars.TOY_TANK_2 then
		Familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
		Familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		if Familiar.Variant == CustomFamiliars.TOY_TANK_1 then
			Familiar:GetData().Data = {lineOfSightDist = 450, lineOfSightAngle = 40, tankVelocityMul = 3.5, 
										tankAttackBuffer = 8, currBuffer = 0, projectileVelocityMul = 20, newRoomAttackHold = 5}
		else
			Familiar:GetData().Data = {lineOfSightDist = 300, lineOfSightAngle = 10, tankVelocityMul = 1.75, 
										tankAttackBuffer = 90, currBuffer = 0, projectileVelocityMul = 10, newRoomAttackHold = 60}
		end		
	end
	
	if Familiar.Variant == CustomFamiliars.SIBLING_1 or Familiar.Variant == CustomFamiliars.SIBLING_2 or Familiar.Variant == CustomFamiliars.FIGHTING_SIBLINGS then
		Familiar:AddToOrbit(25)
		fSprite:Play("Idle")
		fSprite.PlaybackSpeed = 0.75
	end
	
	if Familiar.Variant == CustomFamiliars.SPIRITUAL_RESERVES_MOON or Familiar.Variant == CustomFamiliars.SPIRITUAL_RESERVES_SUN then
		Familiar:AddToOrbit(30)
	end
end
rplus:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, rplus.FamiliarInit)


						-- MC_FAMILIAR_UPDATE --	 								
						------------------------
function rplus:FamiliarUpdate(Familiar)	
	-- wisps buffed by Torn Page
	if Familiar.Variant == FamiliarVariant.WISP
	and Familiar.FrameCount == 5 and Familiar.Player:HasTrinket(CustomTrinkets.TORN_PAGE) then
		Familiar.MaxHitPoints = Familiar.MaxHitPoints * 1.5
		Familiar.HitPoints = Familiar.MaxHitPoints
	end

	if Familiar.Variant == CustomFamiliars.BAG_O_TRASH then 
		Familiar:FollowParent()
		if Familiar:GetSprite():IsFinished("Spawn") or Familiar.FrameCount == 10 then
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
					local NumSpiders = math.random(math.ceil(CustomData.Items.BAG_O_TRASH.Levels * 1.25))
					
					for _ = 1, (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS, true) and NumSpiders + math.random(2) or NumSpiders) do 
						Isaac.Spawn(3, FamiliarVariant.BLUE_SPIDER, 0, Familiar.Position, Vector.Zero, nil) 
					end
				end
			end
			
			Familiar.RoomClearCount = 0
		end
	end
	
	if Familiar.Variant == CustomFamiliars.CHERRY then
		Familiar.Friction = 0
		
		if game:GetRoom():IsClear() then
			Familiar:GetSprite():Play("Collect")
			if Familiar:GetSprite():IsFinished("Collect") then
				Familiar:Remove()
				Isaac.Spawn(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, Familiar.Position, Vector.Zero, nil)
			end
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
				
                if crownTier >= 1 then
					Tear.CollisionDamage = Tear.CollisionDamage * 1.25
					Tear.Scale = Tear.Scale * 1.25
				end
				
				if crownTier == 2 then
					Tear:ChangeVariant(TearVariant.EYE)
					Tear.TearFlags = TearFlags.TEAR_GLOW | TearFlags.TEAR_HOMING | TearFlags.TEAR_POP
				end
			end
			
			Tear:Update()

			if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
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
		elseif Familiar.FrameCount >= 75 or game:GetRoom():IsClear() or Familiar.RoomClearCount == 1 then
			Familiar:Kill()
		end
	end
	
	if Familiar.Variant == CustomFamiliars.TOY_TANK_1 or Familiar.Variant == CustomFamiliars.TOY_TANK_2 then 
		-- moving around (BASEMENT DRIFT YOOO)
		-- change direction naturally; they change direction when colliding with grid automatically
		if game:GetFrameCount() % 48 == 0 then
			Familiar.Velocity = VECTOR_CARDINAL[math.random(#VECTOR_CARDINAL)] * Familiar:GetData().Data.tankVelocityMul
		end
		
		-- correct the velocity when colliding with grid so that the tanks don't move diagonally
		local TX = Familiar.Velocity.X
		local TY = Familiar.Velocity.Y
		if TY > 0 and TX <= TY and TX >= -TY then
			Familiar.Velocity = VECTOR_CARDINAL[1] * Familiar:GetData().Data.tankVelocityMul
		elseif TX > 0 and TY < TX and TY > -TX then
			Familiar.Velocity = VECTOR_CARDINAL[4] * Familiar:GetData().Data.tankVelocityMul
		elseif TX <= 0 and TY < -TX and TY > TX then
			Familiar.Velocity = VECTOR_CARDINAL[2] * Familiar:GetData().Data.tankVelocityMul
		else
			Familiar.Velocity = VECTOR_CARDINAL[3] * Familiar:GetData().Data.tankVelocityMul
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
					and game:GetRoom():GetFrameCount() > Familiar:GetData().Data.newRoomAttackHold then
						if Familiar.Variant == CustomFamiliars.TOY_TANK_1 then
							local tankBullet = Isaac.Spawn(2, TearVariant.METALLIC, 0, Familiar.Position, posDiff * Familiar:GetData().Data.projectileVelocityMul, nil):ToTear()
							tankBullet.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 7 or 3.5)
							
							if Sewn_API then
								if Sewn_API:GetLevel(Familiar:GetData()) >= 1 then
									tankBullet:AddTearFlags(TearFlags.TEAR_HOMING)
								end
								
								if Sewn_API:GetLevel(Familiar:GetData()) == 2 then
									for _, familiarInRoom in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, CustomFamiliars.TOY_TANK_2, -1, false, false)) do
										local tankLaser = EntityLaser.ShootAngle(2,	familiarInRoom.Position, (enemy.Position - familiarInRoom.Position):Normalized():GetAngleDegrees(), 7, Vector.Zero, familiarInRoom)
										tankLaser.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 7 or 3.5)
									end
								end
							end
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
	
	if Familiar.IsFollower and Familiar.Player:GetData().RejectionUsed 
	and not (Familiar.Variant == FamiliarVariant.INCUBUS and Familiar.Player:GetPlayerType() == PlayerType.PLAYER_LILITH) then
		Familiar:Remove()
	end
	
	if Familiar.Variant == CustomFamiliars.ENOCH or Familiar.Variant == CustomFamiliars.ENOCH_B then
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
			Tear.TearFlags = TearFlags.TEAR_TURN_HORIZONTAL
			
			if Familiar.Variant == CustomFamiliars.ENOCH_B then
				Tear:ChangeVariant(TearVariant.ROCK)
				if math.random(100) <= 7 then Tear.TearFlags = Tear.TearFlags | TearFlags.TEAR_RIFT end
				Tear.CollisionDamage = (Familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 8.75 or 4.375)
				for i = 1, 3 do
					local headBloodSpit = Isaac.Spawn(2, TearVariant.BLOOD, 0, Familiar.Position, Vector.FromAngle(math.random(360)) * 1.5, Familiar):ToTear()
					headBloodSpit.FallingSpeed = math.random(-25, -20)
					headBloodSpit.FallingAcceleration = math.random(125, 175) / 100
					headBloodSpit.Scale = headBloodSpit.Scale * math.random(75, 90) / 100
					headBloodSpit.CollisionDamage = 1.25
				end
			end
			
			Tear:Update()

			if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
				Familiar.FireCooldown = 12
			else
				Familiar.FireCooldown = 18
			end
		end

		Familiar.FireCooldown = Familiar.FireCooldown - 1
	end
	
	if Familiar.Variant == CustomFamiliars.SPIRITUAL_RESERVES_MOON or Familiar.Variant == CustomFamiliars.SPIRITUAL_RESERVES_SUN then
		local s = Familiar:GetSprite()
		local player = Familiar.Player
		Familiar.Velocity = Familiar:GetOrbitPosition(Familiar.Player.Position + Familiar.Player.Velocity) - Familiar.Position
		Familiar.OrbitDistance = Vector(20, 20)
		Familiar.OrbitSpeed = 0.03
		
		if Familiar:GetData()['BlockedShots'] == 3 then
			Familiar:GetData()['BlockedShots'] = 0
			s:Play("Death")
			sfx:Play(SoundEffect.SOUND_ISAACDIES, 1, 2, false, 1.5, 0)
			s.PlaybackSpeed = 1
		end
		
		if s:IsPlaying("Death") then
			if s:IsEventTriggered("Remove") then
				Familiar:Remove()
				if Familiar.Variant == CustomFamiliars.SPIRITUAL_RESERVES_MOON then player:GetData()['usedSpiritualReserves'][1] = false
				else player:GetData()['usedSpiritualReserves'][2] = false end
				player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
				player:EvaluateItems()
				Isaac.Spawn(5, 10, HeartSubType.HEART_HALF_SOUL, Familiar.Position, Vector.Zero, Familiar)
			end
		else
			local name
			if Familiar.Variant == CustomFamiliars.SPIRITUAL_RESERVES_MOON then name = 'Moon' else name = 'Sun' end
			local TearVector
			
			if player:GetFireDirection() == Direction.NO_DIRECTION then
				s:Play("Float_" .. name)
				s.PlaybackSpeed = 0.5
			else
				TearVector = DIRECTION_VECTOR[player:GetFireDirection()]
				s:Play("Shoot_" .. name)
			end
			
			if player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and #Isaac.FindByType(1000, EffectVariant.TARGET, -1, false, true) > 0 then
				TearVector = (Isaac.FindByType(1000, EffectVariant.TARGET, -1, false, true)[1].Position - Familiar.Position):Normalized()
				s:Play("Shoot_" .. name)
			end
			
			if Familiar.FireCooldown <= 0 and TearVector then
				local Tear = Familiar:FireProjectile(TearVector):ToTear()
				Tear.TearFlags = Tear.TearFlags | TearFlags.TEAR_SPECTRAL
				Tear.CollisionDamage = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 4.5 or 2.25
				Tear:Update()

				Familiar.FireCooldown = 24
			end

			Familiar.FireCooldown = Familiar.FireCooldown - 1
		end
	end
	
	if Familiar.Variant == CustomFamiliars.FRIENDLY_SACK then 
		local fsp = Familiar:GetSprite()
		
		Familiar:FollowParent()
		if fsp:IsFinished("Spawn") or fsp:IsFinished("Opening")
		or Familiar.FrameCount == 10 then
			fsp.PlaybackSpeed = 1.0
			fsp:Play("FloatDown")
		end
		
		if fsp:IsPlaying("Opening") and fsp:IsEventTriggered("MonsterSpawn") then
			Familiar.Player:UseActiveItem(CollectibleType.COLLECTIBLE_FRIEND_FINDER, false, true, false, false, -1)
		end
	
		if Familiar.RoomClearCount >= 3 then
			if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
				fsp:Play("Opening")
			else
				local friends = {
					FamiliarVariant.BLUE_FLY,
					FamiliarVariant.BLUE_SPIDER,
					FamiliarVariant.DIP,
					FamiliarVariant.MINISAAC,
					FamiliarVariant.BLOOD_BABY,
					FamiliarVariant.WISP
				}
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomInt(6) + 1
				local roll2
				if roll == 1 then
					roll2 = RNGobj:RandomInt(5) + 1
				elseif roll == 3 then
					roll2 = RNGobj:RandomInt(14) + 1
				elseif roll == 4 then
					roll2 = RNGobj:RandomInt(8) + 1
				elseif roll == 5 then
					roll2 = RNGobj:RandomInt(6) + 1
				else
					roll2 = 0
				end
				
				fsp.PlaybackSpeed = 0.5
				fsp:Play("Spawn")
				Isaac.Spawn(3, friends[roll], roll2, Familiar.Position, Vector.Zero, Familiar.Player)
			end
			
			Familiar.RoomClearCount = 0
		end
	end
	
	if Familiar.Variant >= CustomFamiliars.ULTRA_FLESH_KID_L1 and Familiar.Variant <= CustomFamiliars.ULTRA_FLESH_KID_L3 then
		--[[ 
		this is me trying to write full AI for the familiar
		however, I do not want to kill myself doing this so I'll just spawn an invisible Leech like Alt horsemen devs did 
		
		local roomHearts = Isaac.FindByType(5, 10, -1, true, false)
		local roomEnemies = Isaac.FindInRadius(Familiar.Position, 1000, EntityPartition.ENEMY)
		if #roomEnemies > 0 then
			-- attacking enemies
			Familiar:RemoveFromFollowers()
			Familiar.IsFollower = false
			if Familiar:GetData()['closestEnemyToChase'] and not Familiar:GetData()['closestEnemyToChase']:IsDead() then
				Familiar.Velocity = (Familiar:GetData()['closestEnemyToChase'].Position - Familiar.Position):Normalized() * 4.5
			elseif not Familiar:GetData()['closestEnemyToChase'] or Familiar:GetData()['closestEnemyToChase']:IsDead() then
				Familiar:GetData()['closestEnemyToChase'] = findClosestTarget(Familiar, "enemy", roomEnemies)
				Familiar.Velocity = Vector.Zero
			end
		elseif #roomHearts > 0 and (Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L1 or Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L2) then
			-- collecting red heart pickups to evolve (only UFK of levels 1 and 2 can do that)
			Familiar:RemoveFromFollowers()
			Familiar.IsFollower = false
			for _, h in pairs(roomHearts) do if h.SubType < 3 and h.Position:Distance(Familiar.Position) < 15 then
				-- actual collecting
				h:Remove()
				sfx:P lay(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
				Familiar:AddHearts(3 - h.SubType)
				if Familiar.Hearts >= 15 then
					local player = Familiar.Player
					Familiar:Remove()
					if Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L1 then
						player:GetData()['UFCLevel'] = 2
					else
						player:GetData()['UFCLevel'] = 3
					end
					player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
					player:EvaluateItems()
				end
				Familiar:GetData()['closestHeartToChase'] = nil
			end end
			-- chasing a heart
			if Familiar:GetData()['closestHeartToChase'] then
				Familiar.Velocity = (Familiar:GetData()['closestHeartToChase'].Position - Familiar.Position):Normalized() * 3
			else
				Familiar:GetData()['closestHeartToChase'] = findClosestTarget(Familiar, "heart", roomHearts)
				Familiar.Velocity = Vector.Zero
			end
		else
			-- following the player if there's no hearts to pick or no enemies to attack
			Familiar.IsFollower = true
			Familiar:AddToFollowers()
			Familiar:FollowParent()
		end
		
		AND NOW, the easy way to do it:
		--]]
		
		local d = Familiar:GetData()
		local sprite = Familiar:GetSprite()
		
		if not d.helper then
			for _, leech in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.LEECH)) do
				if leech:ToFamiliar().Keys ~= 13 then
					d.helper = leech
					leech:ToFamiliar():AddKeys(13)
					Familiar.Position = leech.Position
					break
				end
			end
		else			
			Familiar.Velocity = d.helper.Velocity 
			Familiar.SplatColor = Color(0,0,0,1)
			d.helper.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			d.helper.Visible = false
			
			-- altering familiar's behaviour via states (can allow for custom attacks and red heart collecting)
			if not d.familiarState then
				d.familiarState = "normal"
			elseif d.familiarState == "normal" then
				if #getRedHeartPickups() > 0
				and (Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L1 or Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L2) 
				and game:GetRoom():IsClear() then
					d.familiarState = "chasing red heart"
				end
				
				sprite:Play("Move")
				
				if game:GetFrameCount() % 6 == 0 then
					Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, Familiar.Position, Vector.Zero, Familiar)
				end
				
				if isRoomFightInProgress(game:GetRoom()) then
					if game:GetFrameCount() % 30 == 0
					and Familiar.Variant > CustomFamiliars.ULTRA_FLESH_KID_L1 then
						for i = 1, 8 do
							local tear = Familiar:FireProjectile(Vector.FromAngle(i * 45))
							tear:ChangeVariant(TearVariant.BLOOD)
							tear.CollisionDamage = Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L2 and 0.75 or 1
						end
					end
					
					if Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L3 and game:GetRoom():GetFrameCount() >= 60 then
						Familiar:GetSprite():Play("MoveBodyOnly")
						local head = Isaac.Spawn(3, CustomFamiliars.ULTRA_FLESH_KID_L3_HEAD, 0, Familiar.Position, Vector.FromAngle(135) * 7.5, Familiar):ToFamiliar()
						sfx:Play(SoundEffect.SOUND_PLOP, 1, 2, false, 1, 0)
						head.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
						head:GetSprite():Play("MoveHeadOnly")
						
						d.familiarState = "headout"
					end					
				end
			elseif d.familiarState == "headout" then
				if not isRoomFightInProgress(game:GetRoom()) then
					d.familiarState = "normal"
					for _, head in pairs(Isaac.FindByType(3, CustomFamiliars.ULTRA_FLESH_KID_L3_HEAD)) do
						head:Remove()
					end
				else
					if game:GetFrameCount() % 16 == 0 then
						for i = 1, 8 do
							local tear = Familiar:FireProjectile(Vector.FromAngle(i * 45 + math.random(-15, 15)))
							tear.FallingSpeed = -25
							tear.FallingAcceleration = 5
							tear:ChangeVariant(TearVariant.BLOOD)
							tear.CollisionDamage = 1
						end
						
						Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, Familiar.Position, Vector.Zero, Familiar):ToEffect().Scale = 1.75
					end
				end
			elseif d.familiarState == "chasing red heart" then
				--[[if Familiar:GetData()['heartToChase'] then
					d.helper.Velocity = (Familiar:GetData()['heartToChase'].Position - d.helper.Position):Normalized() * 4
				else
					Familiar:GetData()['heartToChase'] = findClosestHeart(d.helper, getRedHeartPickups())
				end]]
				
				for _, h in pairs(getRedHeartPickups()) do
					-- instead of collecting red hearts, UFK will now just suck them towards him for better behaviour
					h.Velocity = (Familiar.Position - h.Position):Normalized() * 2.25
					
					if h.Position:Distance(d.helper.Position) < 15 then
						-- actual collecting
						h:Remove()
						sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 2, false, 1, 0)
						local heartPoints = {
							[1] = 2,
							[2] = 1,
							[5] = 4,
							[9] = 2,
							[CustomPickups.TaintedHearts.HEART_HOARDED] = 8
						}
						Familiar:AddHearts(heartPoints[h.SubType])
						
						if Familiar.Hearts >= 15 then
							Familiar:Remove()
							local player = Familiar.Player
							if Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L1 then
								player:GetData()['UFCLevel'] = 2
							else
								player:GetData()['UFCLevel'] = 3
							end
							player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
							player:EvaluateItems()
						end
						d.familiarState = "normal"
					end 
				end
				
				sprite:Play("Move")
			end		
			
			-- manually correcting helper's position and existance, just in case
			if math.abs((d.helper.Position - Familiar.Position).X) > 20 or math.abs((d.helper.Position - Familiar.Position).Y) > 20 then
				Familiar.Position = d.helper.Position
			end
			if not d.helper:Exists() then
				d.helper = nil
			end
		end
	end	
	if Familiar.Variant == CustomFamiliars.ULTRA_FLESH_KID_L3_HEAD then
		if game:GetFrameCount() % 6 == 0 then
			Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, Familiar.Position, Vector.Zero, Familiar)
		end
		
		if Familiar.Velocity:LengthSquared() < 30 then
			Familiar.Velocity = Familiar.Velocity:Resized(5.5)
		end
	end
	
	if Familiar.Variant == CustomFamiliars.HANDICAPPED_PLACARD then
		Familiar.Friction = 0
		if Familiar.RoomClearCount > 0 then 
			Familiar:Remove()
			Familiar.Player:GetData()['areaMult'] = 0
		end
		
		local d = Familiar.Player:GetData()['areaMult']
		local areaMult = d and (1 + d) or 1
		
		for _, enemy in pairs(Isaac.FindInRadius(Familiar.Position, 100 * areaMult, EntityPartition.ENEMY)) do		
			if enemy:IsActiveEnemy(true) then
				if not enemy:GetData().wasNearPlacard then
					enemy:GetData().wasNearPlacard = true
					enemy:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
				elseif (enemy:IsDead() or enemy:HasMortalDamage()) and not enemy:GetData().placardDeathBurst then
					RNGobj:SetSeed(Random() + 1, 1)
					local roll = RNGobj:RandomInt(2) + 1
					
					for i = 1, roll do
						Isaac.Spawn(3, FamiliarVariant.BONE_SPUR, 0, enemy.Position, Vector.FromAngle(math.random(360)) * 2, Familiar)
					end
					enemy:GetData().placardDeathBurst = true
				end
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, rplus.FamiliarUpdate)


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
		if Collider:ToPlayer() and Collider:GetData()['catchingBird'] then
			local player = Collider:ToPlayer()
			
			sfx:Play(SoundEffect.SOUND_SUPERHOLY, 1, 2, false, 1, 0)
			Isaac.Spawn(1000, EffectVariant.POOF01, 0, Familiar.Position, Vector.Zero, nil)
			Familiar:Remove()
			player.Position = DiePos
			player:TryRemoveNullCostume(Costumes.BIRD_OF_HOPE)
			CustomData.Items.BIRD_OF_HOPE.BirdCaught = true
			player:SetMinDamageCooldown(40)
			player:GetData()['catchingBird'] = nil
			player:AddCacheFlags(CacheFlag.CACHE_FLYING)
			player:EvaluateItems()
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
		if Knife.Parent then
			local player = Knife.Parent:ToPlayer()
		elseif Knife.SpawnerEntity then
			local player = Knife.SpawnerEntity:ToPlayer()
		end
		
		if player and player:HasCollectible(CustomCollectibles.CEREMONIAL_BLADE) then
			Knife:GetSprite():ReplaceSpritesheet(0, "gfx/ceremonial_knife.png")
			Knife:GetSprite():LoadGraphics()
			Knife:GetData().IsCeremonial = true
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, rplus.KnifeUpdate)


						-- MC_PRE_PROJECTILE_COLLISION --									
						---------------------------------
function rplus:ProjectileCollision(Projectile, Collider, _)
	-- prevent familiars soaking projectiles shot by friendly monsters
	if Projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then return end

	if Collider.Type == 3 then
		if Collider.Variant == CustomFamiliars.BAG_O_TRASH then
			Projectile:Remove()
			
			if math.random(100) <= TRASHBAG_BREAK_CHANCE 
			and (not Sewn_API or (Sewn_API and Sewn_API:GetLevel(Collider:ToFamiliar():GetData()) < 1)) then
				sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 1, false, 1, 0)
				Collider:ToFamiliar().Player:RemoveCollectible(CustomCollectibles.BAG_O_TRASH)
				if math.random(100) <= 66 then
					Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_BREAKFAST, Collider.Position, Vector.Zero, nil)
				else
					Isaac.Spawn(5, 350, CustomTrinkets.NIGHT_SOIL, Collider.Position, Vector.Zero, nil)
				end
			end
		end
		
		if Collider.Variant == CustomFamiliars.SIBLING_1 or
		Collider.Variant == CustomFamiliars.SIBLING_2 or 
		Collider.Variant == CustomFamiliars.FIGHTING_SIBLINGS then
			Projectile:Remove()
		end
		
		if (Collider.Variant == CustomFamiliars.SPIRITUAL_RESERVES_MOON or
		Collider.Variant == CustomFamiliars.SPIRITUAL_RESERVES_SUN)
		and not Collider:GetSprite():IsPlaying("Death") then
			Projectile:Remove()
			
			if not Collider:GetSprite():IsOverlayPlaying("Hit") then
				if not Collider:GetData()['BlockedShots'] then Collider:GetData()['BlockedShots'] = 1
				else Collider:GetData()['BlockedShots'] = Collider:GetData()['BlockedShots'] + 1 end
				Collider:GetSprite():PlayOverlay("Hit", true)
				sfx:Play(SoundEffect.SOUND_HOLY_MANTLE, 0.5, 2, false, 1.5, 0)
			end
		end
	end
end
rplus:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, rplus.ProjectileCollision)


						-- MC_PRE_PLAYER_COLLISION --										
						-----------------------------
function rplus:PlayerCollision(Player, Collider, _)
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
	
	if Player:HasCollectible(CustomCollectibles.CEILING_WITH_THE_STARS) and Collider.Type == 5 and Collider.Variant == 380 
	and not CustomData.Items.CEILING_WITH_THE_STARS.SleptInBed 
	-- can not sleep in bed while at full health
	and (Player:GetHearts() ~= Player:GetEffectiveMaxHearts() or Player:GetMaxHearts() == 0) then
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
rplus:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, rplus.PlayerCollision, 0)


						-- MC_PRE_SPAWN_CLEAN_AWARD --							
						------------------------------
function rplus:PickupAwardSpawn(_, Pos)
	local room = game:GetRoom()
	local level = game:GetLevel()
	local NoOptionsQQQ = true 	-- does any player have Options? item
	local c = room:GetCenterPos()
	
	if not CustomData then return end
	
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
		
		if player:HasCollectible(CustomCollectibles.RED_KING) and room:GetType() == RoomType.ROOM_BOSS and level:GetStage() < 8 then
			if level:GetCurrentRoomDesc().Data.Weight == 0 then
				-- these are special boss rooms used by Red King
				for i, v in pairs(CustomData.Items.RED_KING.redCrawlspacesData) do
					if v.associatedRoom == level:GetCurrentRoomDesc().Data.Variant then
						v.isRoomDefeated = true
					end
				end
				local Item1 = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
				local Item2 = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_ULTRA_SECRET, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), room:FindFreePickupSpawnPosition(c + Vector(-40, 40), 10, true, false), Vector.Zero, nil)
					Item1:ToPickup().OptionsPickupIndex = 7
					Item2:ToPickup().OptionsPickupIndex = Item1:ToPickup().OptionsPickupIndex
				return true
			else
				-- these are normal boss rooms	
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomInt(4)
				local chapterAdd = (level:GetStage() + 1) // 2
				local isAltPath = level:GetStageType() > 3 and 100 or 0
				
				local redCrawlspace = Isaac.Spawn(6, 334, 0, c, Vector.Zero, nil)
				redCrawlspace.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				redCrawlspace:GetSprite():Play("OpenAnim")
				table.insert(CustomData.Items.RED_KING.redCrawlspacesData, {seed = redCrawlspace.InitSeed,
																			associatedRoom = 44000 + isAltPath + chapterAdd * 10 + roll,
																			isRoomDefeated = false})
			end
		end
		
		if CustomData.Items.VAULT_OF_HAVOC.Data and level:GetCurrentRoomDesc().Data.Weight == 0 then
			-- spawn reward after clearing Vault of Havoc room
			if CustomData.Items.VAULT_OF_HAVOC.SumHP < 120 + 25 * level:GetStage() then 
				Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
				Isaac.Spawn(5, 10, HeartSubType.HEART_SOUL, room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
				Isaac.Spawn(5, 10, HeartSubType.HEART_GOLDEN, room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
			elseif CustomData.Items.VAULT_OF_HAVOC.SumHP < 140 + 30 * level:GetStage() then
				Isaac.Spawn(5, PickupVariant.PICKUP_CHEST, 0, room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
				Isaac.Spawn(5, PickupVariant.PICKUP_LOCKEDCHEST, 0, room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
				Isaac.Spawn(5, 350, 0, room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
			else
				Isaac.Spawn(5, 100, GetUnlockedVanillaCollectible(true, true), room:FindFreePickupSpawnPosition(c + Vector(40, 40), 10, true, false), Vector.Zero, nil)
			end
			
			CustomData.Items.VAULT_OF_HAVOC.EnemyList = {}
			CustomData.Items.VAULT_OF_HAVOC.Data = false 
			CustomData.Items.VAULT_OF_HAVOC.SumHP = 0
			return true
		end
		
		if player:GetData()['enhancedSB'] and room:GetType() == RoomType.ROOM_BOSS 
		and level:GetStage() < 8 and level:GetStage() ~= 6 then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_THERES_OPTIONS) then
				for i = 1, 3 do
					local it = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_DEVIL, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), room:FindFreePickupSpawnPosition(c + Vector(-160 + 80*i, 80), 10, true, false), Vector.Zero, nil):ToPickup()
					it.OptionsPickupIndex = 666
					it.Price = -1
					it.AutoUpdatePrice = true
				end
			else
				for i = 1, 2 do
					local it = Isaac.Spawn(5, 100, game:GetItemPool():GetCollectible(ItemPoolType.POOL_DEVIL, false, Random() + 1, CollectibleType.COLLECTIBLE_NULL), room:FindFreePickupSpawnPosition(c + Vector(-120 + 80*i, 80), 10, true, false), Vector.Zero, nil):ToPickup()
					it.OptionsPickupIndex = 666
					it.Price = -1
					it.AutoUpdatePrice = true
				end
			end
			room:DestroyGrid(room:GetGridIndex(c + Vector(0, -80)), true)
			Isaac.GridSpawn(GridEntityType.GRID_TRAPDOOR, 0, c + Vector(0, -80), true)
			return true
		end
		
		if canOpenScarletChests(player)
		and math.random(100) <= SCARLETCHEST_REPLACE_CHANCE 
		and room:GetType() ~= RoomType.ROOM_BOSS and room:GetType() ~= RoomType.ROOM_BOSSRUSH then
			Isaac.Spawn(5, CustomPickups.SCARLET_CHEST, 0, game:GetRoom():FindFreePickupSpawnPosition(Pos, 0, true, false), Vector.Zero, nil)
			sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 2, false, 1, 0)
			return true
		end
		
		if player:GetData().JewelData_LUST == "isExtra" then
			RNGobj:SetSeed(Random() + 1, 1)
			local roll = RNGobj:RandomFloat() * 100
			
			local extraGoodPickups = {
				{10, {PickupVariant.PICKUP_GRAB_BAG, 1}},
				{20, {PickupVariant.PICKUP_GRAB_BAG, 2}},
				{30, {20, CoinSubType.COIN_DIME}},
				{40, {20, CoinSubType.COIN_LUCKYPENNY}},
				{50, {20, CoinSubType.COIN_NICKEL}},
				{60, {30, KeySubType.KEY_CHARGED}},
				{70, {PickupVariant.PICKUP_CHEST, 0}},
				{80, {PickupVariant.PICKUP_WOODENCHEST, 0}},
				{90, {PickupVariant.PICKUP_LOCKEDCHEST, 0}},
				{100, {PickupVariant.PICKUP_TRINKET, 0}}
			}
			
			for _, subt in pairs(extraGoodPickups) do
				if roll < subt[1] then
					Isaac.Spawn(5, subt[2][1], subt[2][2], game:GetRoom():FindFreePickupSpawnPosition(Pos, 0, true, false), Vector.Zero, nil)
					break
				end
			end
			
			player:GetData().JewelData_LUST = nil
			return true
		end
		if CustomData and CustomData.TaintedHearts.SOILED > 0 then 
			for i = 1, CustomData.TaintedHearts.SOILED*2 do 
				RNGobj:SetSeed(Random() + 1, 1)
				local roll = RNGobj:RandomFloat() * 100
				local randomdip = RNGobj:RandomInt(15)
				if roll < 40 then 
					Isaac.Spawn(3, FamiliarVariant.DIP, randomdip, player.Position,  Vector.Zero, nil)
				end	
			end
		end
	end
	
	
	
	if math.random(100) < JACK_CHANCE and CustomData.Cards.JACK 
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


						-- MC_POST_EFFECT_UPDATE --							
						---------------------------
function rplus:PostEffectUpdate(Effect)
	-- helper for killing stargazer beggars and opening coffins when the explosion is nearby
	if Effect.Variant == EffectVariant.BOMB_EXPLOSION or Effect.Variant == EffectVariant.MAMA_MEGA_EXPLOSION then
		local trueExplosionDist = Effect.Variant == EffectVariant.MAMA_MEGA_EXPLOSION and 1500 or 90
	
		for _, slot in pairs(Isaac.FindByType(6, CustomPickups.SLOT_STARGAZER, -1, false, true)) do
			if slot.Position:Distance(Effect.Position) <= trueExplosionDist then
				slot:Kill()
				slot:Remove()
				game:GetLevel():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
			end
		end
		
		for _, cof in pairs(Isaac.FindByType(5, CustomPickups.COFFIN, -1)) do
			if cof.Position:Distance(Effect.Position) <= trueExplosionDist 
			and (not cof:GetData().ExplodeFrame or game:GetFrameCount() >= cof:GetData().ExplodeFrame + 60) then
				if cof.SubType == 2 or Effect.Variant == EffectVariant.MAMA_MEGA_EXPLOSION then
					-- open coffin
					cof.SubType = 1
					cof:GetData()["IsInRoom"] = true
					cof:GetSprite():Play("Open")
					RNGobj:SetSeed(Random() + 1, 1)
					local player = Isaac.GetPlayer(0)
					local roll = RNGobj:RandomFloat()
					
					if roll < 0.2 then
						local CoffinPedestal1 = Isaac.Spawn(5, 100, GetUnlockedCollectibleFromCustomPool(CustomItempools.COFFIN), cof.Position + Vector(-20, 0), Vector.Zero, cof)
						CoffinPedestal1:GetSprite():ReplaceSpritesheet(5, "gfx/items/coffin_itemaltar_left.png") 
						CoffinPedestal1:GetSprite():LoadGraphics()
						
						local CoffinPedestal2 = Isaac.Spawn(5, 100, GetUnlockedCollectibleFromCustomPool(CustomItempools.COFFIN), cof.Position + Vector(20, 0), Vector.Zero, cof)
						CoffinPedestal2:GetSprite():ReplaceSpritesheet(5, "gfx/items/coffin_itemaltar_right.png") 
						CoffinPedestal2:GetSprite():LoadGraphics()
						
						cof:Remove()
					elseif roll < 0.65 then
						for j = 1, 3 do
							Isaac.Spawn(5, 10, HeartSubType.HEART_BONE, cof.Position, Vector.FromAngle(math.random(360)) * 3, cof)
						end
					else
						for i = 1, 9 do
							Isaac.Spawn(3, FamiliarVariant.BONE_ORBITAL, 0, player.Position, Vector.Zero, player)
						end
						for j = 1, 3 do
							Isaac.Spawn(EntityType.ENTITY_BONY, 0, 0, cof.Position, Vector.Zero, player):AddCharmed(EntityRef(player), -1)
						end
					end
				elseif cof.SubType == 0 then
					cof.SubType = 2
					cof:GetSprite():Play("Exploded")
				end
				
				sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 2, false, 1, 0)
				cof:GetData().ExplodeFrame = game:GetFrameCount()
			end
		end
	end
	
	if Effect.Variant == FallingKnifeHelper then
		local s = Effect:GetSprite()
		
		if s:IsEventTriggered("Fall") then
			Effect.SpawnerEntity:TakeDamage(Effect:GetData().Damage, 0, EntityRef(Effect), 0)
		elseif s:IsEventTriggered("Remove") then
			Effect:Remove()
		end
	end
	
	-- cripple hands
	if Effect.Variant == CripplingHandsHelper then
		if Effect:GetSprite():IsFinished("ClawsAppearing") then Effect:GetSprite():Play("ClawsHolding") end
		
		if not Effect.SpawnerEntity then Effect:Remove()
		else Effect.Position = Effect.SpawnerEntity.Position + Vector(0, 5) end
	end
	
	if Effect.Variant == PlacardBorder then
		if not Effect.SpawnerEntity or not Effect.SpawnerEntity:Exists() then Effect:Remove() end
		
		local d = Effect.SpawnerEntity:ToFamiliar().Player:GetData()['areaMult']
		local m = d or 0
		Effect.SpriteScale = Vector(2.75 * (1 + m), 2.75 * (1 + m))
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, rplus.PostEffectUpdate)


						-- MC_GET_SHADER_PARAMS --										
						--------------------------
function rplus:GetShaderParams(shaderName)
	if not CustomData then return end
	-- only used for rendering Tainted hearts, and ONLY FOR THE MAIN PLAYER !!!
	if shaderName == 'Hearts' then
		HeartRender(Isaac.GetPlayer(0), CustomData.TaintedHearts.DAUNTLESS.Num, "Dauntless")
		HeartRender(Isaac.GetPlayer(0), CustomData.TaintedHearts.SOILED, "Soiled")
		HeartRender(Isaac.GetPlayer(0), CustomData.TaintedHearts.ZEALOT, "Zealot")
		HeartRender(Isaac.GetPlayer(0), CustomData.TaintedHearts.EMPTY, "Empty")
		return nil
	end
end
rplus:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, rplus.GetShaderParams)


---------------------------------------------------------
-- helpers for animating the Angel's Wings' item pedestal
-- code shamelessly stolen from THE ANIMATED ITEMS MOD
-- I hope it was worth it
-- it was!! everyone liked it!!
function rplus:PostPickupRender(pickup)
	if pickup.SubType == CustomCollectibles.ANGELS_WINGS 
	and game:GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND ~= LevelCurse.CURSE_OF_BLIND
	and not hasEffectOnIt(pickup) then
		Isaac.Spawn(1000, AnimatedItemDummyEntity, 0, pickup.Position, Vector.Zero, pickup)
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, rplus.PostPickupRender, PickupVariant.PICKUP_COLLECTIBLE)

function rplus:PostEffectInit(effect)
	local spawner = effect.SpawnerEntity
	
	effect:FollowParent(spawner)
	effect:GetSprite():Load("gfx/AngelsWingsAnimated.anm2", true)
	effect:GetSprite():Play("AnimatedPedestal")
	effect.DepthOffset = 1
	
	if spawner.Type == EntityType.ENTITY_PICKUP and spawner.Variant == PickupVariant.PICKUP_COLLECTIBLE then
		spawner:GetSprite():ReplaceSpritesheet(1, "gfx/nil_pedestal.png")
		spawner:GetSprite():LoadGraphics()
		effect.SpriteOffset = Vector(0, -3)
		if spawner:ToPickup():IsShopItem() then effect.SpriteOffset = Vector(0, 10) end
		
	elseif spawner.Type == EntityType.ENTITY_PLAYER then
		effect.SpriteOffset = Vector(0, -16)
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, rplus.PostEffectInit, AnimatedItemDummyEntity)

function rplus:PostEffectRender(effect)
	local spawner = effect.SpawnerEntity
	if not spawner then effect:Remove() end
	
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		
		if player.QueuedItem.Item and player.QueuedItem.Item.ID == CustomCollectibles.ANGELS_WINGS then
			if not hasEffectOnIt(player) then
				effect:Remove()
				Isaac.Spawn(1000, AnimatedItemDummyEntity, 0, player.Position, Vector.Zero, player)
			end
		end
	end
	
	if spawner.Type == 5 and spawner.Variant == 100 and spawner.SubType == CustomCollectibles.ANGELS_WINGS then
		local frame = spawner:GetSprite():GetFrame()
		
		if not spawner:ToPickup():IsShopItem() then
			local y = 0
			local scale = Vector.One
			
			if frame <= 2 then
				y = -3
			elseif frame <= 4 then
				y = -4
				scale = Vector(1, 1.04)
			elseif frame <= 6 then
				y = -5
				scale = Vector(1.08, 0.98)
			elseif frame <= 8 then
				y = -6
				scale = Vector(1, 1.04)
			elseif frame <= 11 then
				y = -7
			elseif frame <= 13 then
				y = -6
			elseif frame <= 15 then
				y = -5
			elseif frame <= 17 then
				y = -4
				scale = Vector(1.08, 0.98)
			else
				y = -3
				scale = Vector(1.08, 0.98)
			end
			effect.SpriteOffset = Vector(0, y)
			effect.SpriteScale = scale
		else
			effect.SpriteOffset = Vector(0, 10)
			effect.SpriteScale = Vector.One
		end
	elseif spawner.Type == 1 then
		local player = effect.SpawnerEntity:ToPlayer()
		if not player.QueuedItem.Item or player.QueuedItem.Item.ID ~= CustomCollectibles.ANGELS_WINGS then effect:Remove() end
	end
end
rplus:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, rplus.PostEffectRender, AnimatedItemDummyEntity)


								----------------------------------
								--- EXTERNAL ITEM DESCRIPTIONS ---
								----------------------------------
								
if EID then
	include("scripts/EID.lua")
end

								---------------------
								--- ENCYCLOPEDIA  ---
								---------------------

if Encyclopedia then	
	include("scripts/Encyclopedia.lua")
end

								----------------
								--- MINIMAPI ---
								----------------
if MinimapAPI then
	include("scripts/MinimAPI.lua")
end

								----------------------
								--- SEWING MACHINE ---
								----------------------
if Sewn_API then
	-- Tank Boys
	Sewn_API:MakeFamiliarAvailable(CustomFamiliars.TOY_TANK_1, CustomCollectibles.TANK_BOYS)
	Sewn_API:AddFamiliarDescription(CustomFamiliars.TOY_TANK_1, 'The green Tank Boy gains homing ammunition', 'Red Tank Boy will fire lasers at whatever enemy is attacked by the green Tank Boy')
	
	-- Bag-o-Trash
	Sewn_API:MakeFamiliarAvailable(CustomFamiliars.BAG_O_TRASH, CustomCollectibles.BAG_O_TRASH)
    Sewn_API:AddFamiliarDescription(CustomFamiliars.BAG_O_TRASH, 'Bag can no longer be destroyed', 'Bag will also spawn blue spiders on room clear')
	
	-- Cherubim
    Sewn_API:MakeFamiliarAvailable(CustomFamiliars.CHERUBIM, CustomCollectibles.CHERUBIM)
    Sewn_API:AddFamiliarDescription(CustomFamiliars.CHERUBIM, 'Cherubim gains increased God Head aura size and tear damage', 'Cherubim gains Pop! tears')
end

								-------------
								--- S & G ---
								-------------
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


































