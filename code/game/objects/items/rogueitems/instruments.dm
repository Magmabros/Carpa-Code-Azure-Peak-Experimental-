
/obj/item/rogue/instrument
	name = ""
	desc = ""
	icon = 'icons/roguetown/items/music.dmi'
	icon_state = ""
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK_R|ITEM_SLOT_BACK_L
	can_parry = TRUE
	force = 23
	throwforce = 7
	throw_range = 4
	var/datum/looping_sound/dmusloop/soundloop
	var/list/song_list = list()
	var/playing = FALSE

/obj/item/rogue/instrument/equipped(mob/living/user, slot)
	. = ..()
	if(playing && user.get_active_held_item() != src)
		playing = FALSE
		soundloop.stop()

/obj/item/rogue/instrument/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = 0,"sy" = 2,"nx" = 15,"ny" = -4,"wx" = -1,"wy" = 2,"ex" = 7,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/rogue/instrument/Initialize()
	soundloop = new(list(src), FALSE)
//	soundloop.start()
	. = ..()

/obj/item/rogue/instrument/dropped()
	..()
	if(soundloop)
		soundloop.stop()

/obj/item/rogue/instrument/attack_self(mob/living/user)
	var/stressevent = /datum/stressevent/music
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(!playing)
		var/curfile = input(user, "Which song?", "Roguetown", name) as null|anything in song_list
		if(!user)
			return
		if(user.mind)
			soundloop.stress2give = null
			switch(user.mind.get_skill_level(/datum/skill/misc/music))
				if(1)
					stressevent = /datum/stressevent/music
				if(2)
					stressevent = /datum/stressevent/music/two
				if(3)
					stressevent = /datum/stressevent/music/three
				if(4)
					stressevent = /datum/stressevent/music/four
				if(5)
					stressevent = /datum/stressevent/music/five
				if(6)
					stressevent = /datum/stressevent/music/six
		if(playing)
			playing = FALSE
			soundloop.stop()
			return
		if(!(src in user.held_items))
			return
		if(user.get_inactive_held_item())
			playing = FALSE
			soundloop.stop()
			return
		if(curfile)
			curfile = song_list[curfile]
			playing = TRUE
			soundloop.mid_sounds = list(curfile)
			soundloop.cursound = null
			soundloop.start()
		for(var/mob/living/carbon/human/L in viewers(7))
			L.add_stress(stressevent)
			add_sleep_experience(user, /datum/skill/misc/music, user.STAINT)
	else
		playing = FALSE
		soundloop.stop()

/obj/item/rogue/instrument/lute
	name = "lute"
	desc = "Sus elegantes curvas fueron diseñadas para tejer alegres melodias."
	icon_state = "lute"
	song_list = list("A Knight's Return" = 'sound/music/instruments/lute (1).ogg',
	"Amongst Fare Friends" = 'sound/music/instruments/lute (2).ogg',
	"The Road Traveled by Few" = 'sound/music/instruments/lute (3).ogg',
	"Tip Thine Tankard" = 'sound/music/instruments/lute (4).ogg',
	"A Reed On the Wind" = 'sound/music/instruments/lute (5).ogg',
	"Jests On Steel Ears" = 'sound/music/instruments/lute (6).ogg',
	"Merchant in the Mire" = 'sound/music/instruments/lute (7).ogg')

/obj/item/rogue/instrument/accord
	name = "accordion"
	desc = "Un recipiente armonioso de nostalgia, recuerdos, festejos y celebracion."
	icon_state = "accordion"
	song_list = list("Her Healing Tears" = 'sound/music/instruments/accord (1).ogg',
	"Peddler's Tale" = 'sound/music/instruments/accord (2).ogg',
	"We Toil Together" = 'sound/music/instruments/accord (3).ogg',
	"Just One More, Tavern Wench" = 'sound/music/instruments/accord (4).ogg',
	"Moonlight Carnival" = 'sound/music/instruments/accord (5).ogg',
	"'Ye Best Be Goin'" = 'sound/music/instruments/accord (6).ogg',
	"Beloved Blue" = 'sound/music/instruments/accord (7).ogg')

/obj/item/rogue/instrument/guitar
	name = "guitar"
	desc = "Esta es una guitarra, el instrumento elegido por los errantes y los desconsolados." // YIPPEE I LOVE GUITAR
	icon_state = "guitar"
	song_list = list("Fire-Cast Shadows" = 'sound/music/instruments/guitar (1).ogg',
	"The Forced Hand" = 'sound/music/instruments/guitar (2).ogg',
	"Regrets Unpaid" = 'sound/music/instruments/guitar (3).ogg',
	"'Took the Mammon and Ran'" = 'sound/music/instruments/guitar (4).ogg',
	"Poor Man's Tithe" = 'sound/music/instruments/guitar (5).ogg',
	"In His Arms Ye'll Find Me" = 'sound/music/instruments/guitar (6).ogg',
	"El Odio" = 'sound/music/instruments/guitar (7).ogg',
	"Danza De Las Lanzas" = 'sound/music/instruments/guitar (8).ogg',
	"The Feline, Forever Returning" = 'sound/music/instruments/guitar (9).ogg',
	"El Beso Carmesí" = 'sound/music/instruments/guitar (10).ogg',
	"The Queen's High Seas" = 'sound/music/instruments/guitar (11).ogg')

/obj/item/rogue/instrument/harp
	name = "harp"
	desc = "Un arpa de la fina artesania de los elfos."
	icon_state = "harp"
	song_list = list("Through Thine Window, He Glanced" = 'sound/music/instruments/harb (1).ogg',
	"The Lady of Red Silks" = 'sound/music/instruments/harb (2).ogg',
	"Eora Doth Watches" = 'sound/music/instruments/harb (3).ogg')

/obj/item/rogue/instrument/flute
	name = "flute"
	desc = "Una flauta delgada, cuidadosamente tallada a partir de una pieza de madera lisa"
	icon_state = "flute"
	song_list = list("Half-Dragon's Ten Mammon" = 'sound/music/instruments/flute (1).ogg',
	"'The Local Favorite'" = 'sound/music/instruments/flute (2).ogg',
	"Rous in the Cellar" = 'sound/music/instruments/flute (3).ogg',
	"Her Boots, So Incandescent" = 'sound/music/instruments/flute (4).ogg',
	"Moondust Minx" = 'sound/music/instruments/flute (5).ogg',
	"Quest to the Ends" = 'sound/music/instruments/flute (6).ogg',
	"Spit Shine" = 'sound/music/instruments/flute (7).ogg')

/obj/item/rogue/instrument/drum
	name = "drum"
	desc = "Confeccionado con pieles tirantes en un robusto marco, palpita como el latido de un corazon gigantesco."
	icon_state = "drum"
	song_list = list("Barbarian's Moot" = 'sound/music/instruments/drum (1).ogg',
	"Muster the Wardens" = 'sound/music/instruments/drum (2).ogg',
	"The Earth That Quakes" = 'sound/music/instruments/drum (3).ogg')
