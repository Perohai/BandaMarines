//Best ert ever

/datum/emergency_call/souto
	name = "Souto Man"
	mob_max = 1
	mob_min = 1
	objectives = "Устройте вечеринку, будто это снова 1999!"
	probability = 0

/datum/emergency_call/souto/New()
	arrival_message = "Поаплодируйте морпеху, который прислал десять тысяч марок Соуто, чтобы вытащить меня сюда! [MAIN_SHIP_NAME], Соуто прибыл, чтобы повеселиться с ВАМИ!"
	return ..()

/datum/emergency_call/souto/create_member(datum/mind/M, turf/override_spawn_loc)
	var/turf/spawn_loc = override_spawn_loc ? override_spawn_loc : get_spawn_point()

	if(!istype(spawn_loc))
		return //Didn't find a useable spawn point.

	var/mob/living/carbon/human/H = new(spawn_loc)
	M.transfer_to(H, TRUE)

	arm_equipment(H, /datum/equipment_preset/other/souto, TRUE, TRUE)

	to_chat(H, SPAN_ROLE_HEADER("You are Souto Man! You should bring awareness to the Souto brand!"))
	to_chat(H, SPAN_ROLE_BODY("Your job is to party hard and share Souto. Make sure those marines are never thirsty again!"))

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), H, SPAN_BOLD("Objectives: [objectives]")), 1 SECONDS)

/datum/emergency_call/souto/cryo
	name = "Souto Man (Cryo)"
	probability = 0
	name_of_spawn = /obj/effect/landmark/ert_spawns/distress_cryo
	shuttle_id = ""
