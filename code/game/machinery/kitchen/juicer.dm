
/obj/structure/machinery/juicer
	name = "Juicer"
	icon = 'icons/obj/structures/machinery/kitchen.dmi'
	icon_state = "juicer1"
	layer = ABOVE_TABLE_LAYER
	density = FALSE
	anchored = FALSE
	wrenchable = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 5
	active_power_usage = 100
	var/obj/item/reagent_container/beaker = null
	var/global/list/allowed_items = list (
		/obj/item/reagent_container/food/snacks/grown/tomato  = "tomatojuice",
		/obj/item/reagent_container/food/snacks/grown/carrot  = "carrotjuice",
		/obj/item/reagent_container/food/snacks/grown/berries = "berryjuice",
		/obj/item/reagent_container/food/snacks/grown/banana  = "banana",
		/obj/item/reagent_container/food/snacks/grown/potato = "potato",
		/obj/item/reagent_container/food/snacks/grown/lemon = "lemonjuice",
		/obj/item/reagent_container/food/snacks/grown/orange = "orangejuice",
		/obj/item/reagent_container/food/snacks/grown/lime = "limejuice",
		/obj/item/reagent_container/food/snacks/watermelonslice = "watermelonjuice",
		/obj/item/reagent_container/food/snacks/grown/grapes = "grapejuice",
		/obj/item/reagent_container/food/snacks/grown/poisonberries = "poisonberryjuice",
	)

/obj/structure/machinery/juicer/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_container/glass/beaker/large(src)

/obj/structure/machinery/juicer/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/structure/machinery/juicer/update_icon()
	icon_state = "juicer"+num2text(!QDELETED(beaker))
	return


/obj/structure/machinery/juicer/attackby(obj/item/O as obj, mob/user as mob)
	if(HAS_TRAIT(O, TRAIT_TOOL_WRENCH))
		. = ..()
	if (istype(O,/obj/item/reagent_container/glass) || \
		istype(O,/obj/item/reagent_container/food/drinks/drinkingglass))
		if (beaker)
			return 1
		else
			if(user.drop_held_item())
				O.forceMove(src)
				beaker = O
				verbs += /obj/structure/machinery/juicer/verb/detach
				update_icon()
			updateUsrDialog()
			return 0
	if (!is_type_in_list(O, allowed_items))
		to_chat(user, "It looks as not containing any juice.")
		return 1
	if(user.drop_held_item())
		O.forceMove(src)
	updateUsrDialog()
	return 0

/obj/structure/machinery/juicer/attack_remote(mob/user as mob)
	return 0

/obj/structure/machinery/juicer/attack_hand(mob/user as mob)
	user.set_interaction(src)
	interact(user)

/obj/structure/machinery/juicer/interact(mob/user as mob) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""

	for (var/i in allowed_items)
		for (var/obj/item/O in src.contents)
			if (!istype(O,i))
				continue
			processing_chamber+= "some <B>[O]</B><BR>"
			break
	if (!processing_chamber)
		is_chamber_empty = 1
		processing_chamber = "Nothing."
	if (!beaker)
		beaker_contents = "\The [src] has no beaker attached."
	else if (!beaker.reagents.total_volume)
		beaker_contents = "\The [src]  has attached an empty beaker."
		is_beaker_ready = 1
	else if (beaker.reagents.total_volume < beaker.reagents.maximum_volume)
		beaker_contents = "\The [src]  has attached a beaker with something."
		is_beaker_ready = 1
	else
		beaker_contents = "\The [src]  has attached a beaker and beaker is full!"

	var/dat = {"
<b>Processing chamber contains:</b><br>
[processing_chamber]<br>
[beaker_contents]<hr>
"}
	if (is_beaker_ready && !is_chamber_empty && !(inoperable()))
		dat += "<A href='byond://?src=\ref[src];action=juice'>Turn on!<BR>"
	if (beaker)
		dat += "<A href='byond://?src=\ref[src];action=detach'>Detach a beaker!<BR>"
	show_browser(user, dat, "Juicer", "juicer")
	onclose(user, "juicer")
	return


/obj/structure/machinery/juicer/Topic(href, href_list)
	if(..())
		return
	usr.set_interaction(src)
	switch(href_list["action"])
		if ("juice")
			juice()

		if ("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/structure/machinery/juicer/verb/detach()
	set category = "Object"
	set name = "Detach Beaker from the juicer"
	set src in oview(1)
	if (usr.stat != 0)
		return
	if (!beaker)
		return
	verbs -= /obj/structure/machinery/juicer/verb/detach
	beaker.forceMove(src.loc)
	beaker = null
	update_icon()

/obj/structure/machinery/juicer/proc/get_juice_id(obj/item/reagent_container/food/snacks/grown/O)
	for (var/i in allowed_items)
		if (istype(O, i))
			return allowed_items[i]

/obj/structure/machinery/juicer/proc/get_juice_amount(obj/item/reagent_container/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return floor(5*sqrt(O.potency))

/obj/structure/machinery/juicer/proc/juice()
	power_change() //it is a portable machine
	if(inoperable())
		return
	if (!beaker || beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
		return
	playsound(src.loc, 'sound/machines/juicer.ogg', 25, 1)
	for (var/obj/item/reagent_container/food/snacks/O in src.contents)
		var/r_id = get_juice_id(O)
		beaker.reagents.add_reagent(r_id,get_juice_amount(O))
		qdel(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

/obj/structure/machinery/juicer/yautja
	name = "bone grinder"
	icon = 'icons/obj/structures/machinery/yautja_machines.dmi'

/obj/structure/closet/crate/juice

/obj/structure/closet/crate/juice/Initialize()
	. = ..()
	new/obj/structure/machinery/juicer(src)
	new/obj/item/reagent_container/food/snacks/grown/tomato(src)
	new/obj/item/reagent_container/food/snacks/grown/carrot(src)
	new/obj/item/reagent_container/food/snacks/grown/berries(src)
	new/obj/item/reagent_container/food/snacks/grown/banana(src)
	new/obj/item/reagent_container/food/snacks/grown/tomato(src)
	new/obj/item/reagent_container/food/snacks/grown/carrot(src)
	new/obj/item/reagent_container/food/snacks/grown/berries(src)
	new/obj/item/reagent_container/food/snacks/grown/banana(src)
	new/obj/item/reagent_container/food/snacks/grown/tomato(src)
	new/obj/item/reagent_container/food/snacks/grown/carrot(src)
	new/obj/item/reagent_container/food/snacks/grown/berries(src)
	new/obj/item/reagent_container/food/snacks/grown/banana(src)

