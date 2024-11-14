#define EQUALIZED_GLOW "equalizer glow"

// T0: Determine the net mammon value of target

/obj/effect/proc_holder/spell/invoked/appraise
	name = "Appraise"
	overlay_state = "appraise"
	releasedrain = 10
	chargedrain = 0
	chargetime = 0
	range = 2
	warnie = "sydwarning"
	movement_interrupt = FALSE
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	charge_max = 5 SECONDS 
	miracle = TRUE
	devotion_cost = 0 


/obj/effect/proc_holder/spell/invoked/appraise/cast(list/targets, mob/living/user)
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/target = targets[1]
		var/mammonsonperson = get_mammons_in_atom(target)
		var/mammonsinbank = SStreasury.bank_accounts[target]
		var/totalvalue = mammonsinbank + mammonsonperson
		to_chat(user, ("<font color='yellow'>[target] tiene [mammonsonperson] mammones en ellos, [mammonsinbank] en su meister, para un total de [totalvalue] mammones.</font>"))

// T1 - Take value of item in hand, apply that as healing. Destroys item.

/obj/effect/proc_holder/spell/invoked/transact
	name = "Transact"
	overlay_state = "transact"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	range = 4
	warnie = "sydwarning"
	movement_interrupt = FALSE
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	charge_max = 20 SECONDS
	miracle = TRUE
	devotion_cost = 20


/obj/effect/proc_holder/spell/invoked/transact/cast(list/targets, mob/living/user)
	. = ..()
	var/obj/item/held_item = user.get_active_held_item()
	if(!held_item)
		to_chat(user, span_info("Necesito algo de valor para hacer una transaccion..."))
		return
	var/helditemvalue = held_item.get_real_price()
	if(!helditemvalue)
		to_chat(user, span_info("Esto no tiene valor, no sera de ningun uso En tal transaccion."))
		return
	if(helditemvalue<10)
		to_chat(user, span_info("Esto tiene poco valor, no sera de ningun uso En tal transaccion."))
		return
	if(isliving(targets[1]))
		var/mob/living/target = targets[1]
		user.visible_message(span_notice("La transaccion se realiza, ¡[target] es bañado en empoderamiento!"))
		to_chat(user, "<font color='yellow'>[held_item] se quema en el aire de repente, mi Transaccion es aceptada..</font>")
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			var/datum/status_effect/buff/healing/heal_effect = C.apply_status_effect(/datum/status_effect/buff/healing)
			heal_effect.healing_on_tick = helditemvalue/2
			playsound(user, 'sound/combat/hits/burn (2).ogg', 100, TRUE)
			qdel(held_item)
		else
			target.adjustBruteLoss(helditemvalue/2)
			target.adjustFireLoss(helditemvalue/2)
			playsound(user, 'sound/combat/hits/burn (2).ogg', 100, TRUE)
			qdel(held_item)
		return TRUE
	revert_cast()
	return FALSE

// T2 We're going to debuff a targets stats = to the difference between us and them in total stats. 

/obj/effect/proc_holder/spell/invoked/equalize
	name = "Equalize"
	overlay_state = "equalize"
	clothes_req = FALSE
	overlay_state = "equalize"
	associated_skill = /datum/skill/magic/holy
	chargedloop = /datum/looping_sound/invokeascendant
	chargedrain = 0
	chargetime = 50
	releasedrain = 60
	no_early_release = TRUE
	antimagic_allowed = TRUE
	movement_interrupt = FALSE
	charge_max = 2 MINUTES
	range = 4
	var/totalstatshift = 0
	var/totalstatchange = 0
	var/outline_colour = "#FFD700"
/obj/effect/proc_holder/spell/invoked/equalize/cast(list/targets, mob/living/user)
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/target = targets[1]
		totalstatchange += (target.STASPD-user.STASPD)
		totalstatchange += ((target.STASTR-user.STASTR)*2) // We're gonna weigh strength as double, being the strongest stat.
		totalstatchange += (target.STAEND-user.STAEND)
		totalstatchange += (target.STALUC-user.STALUC)
		totalstatchange += (target.STAINT-user.STAINT)
		totalstatchange += (target.STACON-user.STACON)
		totalstatchange += (target.STAPER-user.STAPER)
		totalstatchange -=3 // We need Atleast a 4 point disadvantage before we start siphoning
		totalstatshift = CLAMP((totalstatchange), 0, 2) // We DO NOT WANT Matthian Clerics stealing 30 stats from Ascendants, Cap the statshift by 2
		if(totalstatshift <1)
			to_chat(user, "<font color='yellow'>[target] fire burns dimly, there is nothing worth equalizing.</font>")
			return
		else
			// there is SURELY a better way to do this
			playsound(user, 'sound/magic/swap.ogg', 100, TRUE)
			user.add_filter(EQUALIZED_GLOW, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))
			target.add_filter(EQUALIZED_GLOW, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 200, "size" = 1))
			to_chat(target, span_danger("Siento que mi llama esta siendo desviada!"))
			to_chat(user, "<font color='yellow'>El vinculo de ecualizacion esta hecho, estoy extrayendo llama!</font>")
			target.STASPD -= totalstatshift // LALA LA NOTHING TO SEE DOWN HERE OFFICER
			user.STASPD += totalstatshift
			target.STASTR -= totalstatshift
			user.STASTR += totalstatshift
			target.STAEND -=totalstatshift
			user.STAEND += totalstatshift
			target.STALUC -= totalstatshift
			user.STALUC += totalstatshift
			target.STAINT -= totalstatshift
			user.STAINT += totalstatshift
			target.STACON -= totalstatshift
			user.STACON += totalstatshift
			target.STAPER -= totalstatshift
			user.STAPER += totalstatshift
			addtimer(CALLBACK(src, PROC_REF(returnstatstarget), target), 1 MINUTES) // 2 timers incase only one guy gets deleted or smthing
			addtimer(CALLBACK(src, PROC_REF(returnstatsuser), user), 1 MINUTES)
			return
			
/obj/effect/proc_holder/spell/invoked/equalize/proc/returnstatstarget(mob/living/target)
	target.remove_filter(EQUALIZED_GLOW)
	target.STASPD += totalstatshift
	target.STASTR += totalstatshift
	target.STAEND += totalstatshift
	target.STALUC += totalstatshift
	target.STAINT += totalstatshift
	target.STACON += totalstatshift
	target.STAPER += totalstatshift
	to_chat(target, span_danger("Siento que mi fuerza volvio hacia mi!"))

/obj/effect/proc_holder/spell/invoked/equalize/proc/returnstatsuser(mob/living/user)
	user.remove_filter(EQUALIZED_GLOW)
	user.STASTR -= totalstatshift
	user.STASPD -= totalstatshift
	user.STAEND -= totalstatshift
	user.STALUC -= totalstatshift
	user.STAINT -= totalstatshift
	user.STACON -= totalstatshift
	user.STAPER -= totalstatshift
	to_chat(user, "<font color='yellow'>Mi vinculo se disipa, su fuego robado vuelve a ellos.</font>")

//T3 COUNT WEALTH, HURT TARGET/APPLY EFFECTS BASED ON AMOUNT OF WEALTH. AT 500+, OLD STYLE CHURNS THE TARGET.

/obj/effect/proc_holder/spell/invoked/churnwealthy
	name = "Churn Wealthy"
	desc = "Empoderar a los debiles a menudo implica destruir a los fuertes."
	clothes_req = FALSE
	overlay_state = "churnwealthy"
	associated_skill = /datum/skill/magic/holy
	chargedloop = /datum/looping_sound/invokeascendant
	chargedrain = 0
	chargetime = 50
	releasedrain = 90
	no_early_release = TRUE
	antimagic_allowed = TRUE
	movement_interrupt = FALSE
	charge_max = 2 MINUTES
	range = 4


/obj/effect/proc_holder/spell/invoked/churnwealthy/cast(list/targets, mob/living/user)
	if(ishuman(targets[1]))
		var/mob/living/carbon/human/target = targets[1]
		var/mammonsonperson = get_mammons_in_atom(target)
		var/mammonsinbank = SStreasury.bank_accounts[target]
		var/totalvalue = mammonsinbank + mammonsonperson
		if(HAS_TRAIT(target, TRAIT_NOBLE))
			totalvalue += 101 // We're ALWAYS going to do a medium level smite minimum to nobles.
		if(totalvalue <=10)
			to_chat(user, "<font color='yellow'>[target] no tiene riqueza para sostener contra ellos.</font>")
			return
		if(totalvalue <=30)
			user.say("La riqueza se convierte en afliccion!")
			target.visible_message(span_danger("[target] es quemado por la luz sagrada!"), span_userdanger("¡Siento el peso de mi riqueza quemando mi alma!"))			
			target.adjustFireLoss(30)
			playsound(user, 'sound/magic/churn.ogg', 100, TRUE)
			return
		if(totalvalue <=60)
			user.say("La riqueza se convierte en afliccion!")
			target.visible_message(span_danger("[target] es quemado por la luz sagrada!"), span_userdanger("¡Siento el peso de mi riqueza quemando mi alma!"))			
			target.adjustFireLoss(30)
			target.adjustFireLoss(60)
			playsound(user, 'sound/magic/churn.ogg', 100, TRUE)
			return
		if(totalvalue <=100)
			user.say("La riqueza se convierte en afliccion!")
			target.visible_message(span_danger("[target] es quemado por la luz sagrada!"), span_userdanger("¡Siento el peso de mi riqueza quemando mi alma!"))			
			target.adjustFireLoss(80)
			target.Stun(20)
			playsound(user, 'sound/magic/churn.ogg', 100, TRUE)
			return
		if(totalvalue <=200)
			user.say("El Dios Libre reprende!")
			target.visible_message(span_danger("[target] es quemado por la luz sagrada!"), span_userdanger("¡Siento el peso de mi riqueza quemando mi alma!"))			
			target.adjustFireLoss(100)
			target.adjust_fire_stacks(7)
			target.Stun(20)
			target.IgniteMob()
			playsound(user, 'sound/magic/churn.ogg', 100, TRUE)
			return
		if(totalvalue <=500)
			user.say("El Dios Libre reprende!")
			target.visible_message(span_danger("[target] es quemado por la luz sagrada!"), span_userdanger("¡Siento el peso de mi riqueza quemando mi alma!"))			
			target.adjustFireLoss(120)
			target.adjust_fire_stacks(9)
			target.IgniteMob()
			target.Stun(40)
			playsound(user, 'sound/magic/churn.ogg', 100, TRUE)
			return
		if(totalvalue >= 501)
			target.visible_message(span_danger("[target] es quemado por la luz sagrada!"), span_userdanger("¡Siento el peso de mi riqueza quemando mi alma!"))			
			user.say("Tu transaccion final! El Dios Libre reprende!!!")
			target.Stun(60)
			target.emote("agony")
			playsound(user, 'sound/magic/churn.ogg', 100, TRUE)
			explosion(get_turf(target), light_impact_range = 1, flame_range = 1, smoke = FALSE)
			return