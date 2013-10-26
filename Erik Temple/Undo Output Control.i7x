Version 3/110717 of Undo Output Control by Erik Temple begins here.


Section - Control over saving undo state

Save undo state is a truth state that varies. Save undo state is usually true.

To disable saving of/-- undo state: now save undo state is false.
To enable saving of/-- undo state: now save undo state is true.

The report undo saving suspended rules are a rulebook.


Section - Word constants

To decide which value is undo word #1:
	(- 'undo' -)
	
To decide which value is undo word #2:
	(- 'undo' -)
	
To decide which value is undo word #3:
	(- 'undo' -)
	
To decide which value is oops word #1:
	(- 'oops' -)

To decide which value is oops word #2:
	(- 'o//' -)
	
To decide which value is oops word #3:
	(- 'oops' -)
		if ( (+ temporary undo suspension +) ) { return; }
		
		if ((+ save undo state +)) FollowRulebook( (+ report undo saving suspended rules +) );

		if ((+ save undo state +)) FollowRulebook( (+ report undo saving suspended rules +) );


Section - Undo save control

Include (-
[ VM_Undo result_code;
	@restoreundo result_code;
	return (~~result_code);
];

[ VM_Save_Undo result_code;
    if (+ save undo state +) {
       @saveundo result_code;
       if (result_code == -1) { GGRecoverObjects(); return 2; }
       return (~~result_code);
   }
   else { return -2 ; }
];
-) instead of "Undo" in "Glulx.i6t".


Include (-

[ VM_Undo result_code;
	@restore_undo result_code;
	  return result_code;
];

[ VM_Save_Undo result_code;
    if (+ save undo state +) {
       @save_undo result_code;
	return result_code;
    }
    else { return -2; }
];

-) instead of "Undo" in "ZMachine.i6t".


---- DOCUMENTATION ----

Undo Output Control patches the I6 template routines Keyboard(); and Perform_Undo(); so that we can use I7 rulebooks to hook into the UNDO command. These allow us to do anything we like--write new messages for UNDO responses and error text, keep track of variables (partially) independently of the game state as restored by UNDO, and even suspend UNDO programmatically.

Undo Output Control is compatible with Conditional Undo by Jesse McGrew, which provides a more flexible framework for undo prevention. Using the extension with Conditional Undo does change some aspects of usage; see below.

Section - Output rules

The basic rulebooks provided by Undo Output Control are:
	
	(1) before undoing an action rules 
	(2) after undoing an action rules 
	(3) report undoing an action rules

These rulebooks provide hooks into the following "moments" in the UNDO process: (1) before testing whether UNDO is allowed/possible; (2) after an action has been _successfully_ undone; and (3) after an action has been successfully undone but immediately before it is reported, optionally allowing us to replace Inform's default output with our own. The report undoing an action rules should end explicitly in either success or failure. The rulebook will end in failure by default, which means that Inform's default reporting for UNDO will be printed. If you want to substitute Inform's reporting with your own, end your report undoing an action rule with "rule succeeds" or equivalent (see the example for a demonstration).

The same is true of the more specialized rules:

	report prevented undo rules
	report interpreter-undo-incapacity rules
	report interpreter undo failure rules
	report nothing to be undone failure rules

All of these also require a rule to end explictly with "success" in order to replace the default output.

A number of rules are provided as "before" and "after" counterparts of these rules:

	before prevented undo rules
	after prevented undo rules
	before interpreter-undo-incapacity rules
	after interpreter-undo-incapacity rules
	before interpreter undo failure rules
	after interpreter undo failure rules
	before nothing to be undone failure rules
	after nothing to be undone failure rules
	
The before, after, and report prevented undo rules apply only when Inform's built-in use undo prevention option is enabled.

It should be emphasized that, though these rules look like standard action rulebooks, they are not. UNDO is not an action, and these rules are limited to imitating the appearance of action rules. This is why "check undoing" and "instead of undoing" rulebooks are not provided. We have hooks into the output, but little else.

However, it should be noted that when the before undoing an action rulebook ends in explicit failure, undo will be prevented from occurring; this is one way (perhaps the simplest) of disabling UNDO. An example:

	Before undoing an action when the player is tired:
		say "You are too tired to bend space-time to your will.";
		rule fails.

The "Breaking Glass" example provides examples of ways to use both the before and after undoing entry points to accomplish interesting effects.


Section - Undo suspension

Undo Output Control provides a second mechanism for suspending UNDO. To turn UNDO on and off at will, we simply use these phrases:

	suspend undo
	reinstate undo

Note that these will not function if we have used Inform's built-in undo prevention, which functions globally. 

We can also test whether UNDO is disabled using the "if undo is suspended" condition. 

Finally, a rulebook is provided that allows us to control the reporting of a failed attempt to UNDO while undo is suspended:

	report attempt to undo-while-disabled rules

By default, these rules print the message "That action cannot be undone."

Be warned that if the player types UNDO immediately after you have reinstated it, there may be unexpected behavior, as the game can revert to the suspended state, but in such a way that the report attempt to undo-while-disabled rules do not fire.


Section - Removing the option to UNDO at the end of the game

Note that the "before undoing an action rule" is NOT consulted after the game has finished, so we will not be able to use it to block UNDO at that point. Instead, we should simply remove UNDO from the list of options that are presented at the end of the game ("Would you like to RESTART, RESTORE a saved game, QUIT or UNDO the last command?"). We can do so by removing it from the Table of Final Question Options, like this:

	When play begins:
		choose row with a final response rule of immediately undo rule in the Table of Final Question Options; 
		delete the final question wording entry.

This can be done conditionally if needed. We just need to delete the table row before the command to end the game.


Section - Temporary suspension of game state saving

Each turn, after the player has entered a command but before the command is parsed, Inform saves the state of the game into memory. This is the saved state to which the next UNDO command will revert. We can stop the game from saving the undo state, if desired. Once we've disabled saving, an UNDO typed later will revert back to the last saved state. If there are no saved undo states available, a message will print ("You cannot undo any further" by default).

Undo Output Control provides the following phrases for controlling undo saves:

	disable saving of undo state
	enable saving of undo state

See the "Purgatory" example below for a demonstration of how this feature might be used.


Section - Using this extension with Conditional Undo by Jesse McGrew

Jesse McGrew's Conditional Undo extension is compatible with Undo Output Control. It provides an activity-based interface to undo suspension which some authors may prefer. If Conditional Undo is included in our project, the "suspend undo" and "reinstate undo" phrases provided by Undo Output Control will not be available. IMPORTANT: The directive to include Conditional Undo must appear in your source text before the instruction to include Undo Output Control, or the extensions will not function as expected.

Instead of using the "report attempt to undo-while-disabled" rulebook to respond to suspended UNDO, users of Conditional Undo should use the "rule for deciding whether to allow undo" activity (see the Conditional Undo documentation).


Section - Changing vocabulary for UNDO and OOPS

As was mentioned above, UNDO is not an action. Along with OOPS, it is handled before the player's command is actually parsed. To decide whether the player has typed either of these commands, Inform looks at the first word--only!--of the player's input and compares it to a character string (defined as an I6 constant). Because there is no I7 type that is exactly equivalent to this I6 type, it is quite difficult for I7 writers to add to or change the vocabulary associated with these commands.

Undo Output Control makes providing new vocabulary for UNDO and OOPS a bit easier. Each command has three "words" associated with it. These are, with their initial values:

	UNDO					OOPS
	undo word #1 "undo"		oops word #1 "oops"
	undo word #2	"undo"		oops word #2 "o//"
	undo word #3	"undo"		oops word #3 "oops"

We can thus add up to two vocabulary words for each command, in addition to the standard "oops" and "undo", or we can replace all three slots for each word if we like. Note that oops word #2 is a single-letter abbreviation; two forward slashes are required after single-letter words for Inform to understand them.

To change one of these vocabulary words, we need to define a phrase. For example:

	To decide which value is undo word #3:
		(- 'revert' -)

The word must be placed within single quotes, and only a single word can be matched. If your text contains a space, it will never be matched.


Section - Change log

	v3 - Removed unnecessary check of the "before undoing an action" rulebook at the end of the game. This caused an UNDO typed at the end of the game to fail silently.

	v2 - Added suspension of game state saving and the Breaking Glass and Purgatory examples. Also added the ability to change word constants. Fixed minor bug in operation of undo suspension.

	v1 - Initial release.


Example: * Mynah Undo - Presents report rules that reproduce Inform's default output. 

	*: "Mynah Undo"
	


Example: ** I Love the Sound of Breaking Glass - This example shows how to rework the output for UNDO using "report undoing an action", as well as how to limit both the total number of UNDOs available and the number of consecutive UNDOs allowed.

Limiting the total number of UNDOs available is simple. After undoing an action, we decrease the number of UNDOs available. Before undoing an action, we check to see whether there are any UNDOs left. However, this method will only work if the player is limited to one UNDO in a row—otherwise, the game state will be turned back another turn and Inform will "forget" that it had decremented the count. (One solution to this for Glulx games might be to write the number of UNDOs available to an external file, where the value can be tracked independently of the game state.)

To limit the player to taking back just one turn, we use a global variable, "current turn undone". We set this variable to true in the "after undoing an action" rules, and then, if the player tries another UNDO, we can stop it with a "before undoing an action when current turn undone is true" rule. In the every turn rules, which run at the end of a normal turn, we reset the current turn undone variable to false, allowing the player to UNDO once again.

Note that Inform saves the game state even for out-of-world actions, so if the player types SCORE and then UNDO, we only undo as far as the game state before SCORE was typed. 

	*: "I Love the Sound of Breaking Glass"

	Include Undo Output Control by Erik Temple.
	
	Report undoing an action:
		say "[bracket]Previous turn undone.[close bracket][line break]";
		try looking;
		rule succeeds.
	
	Current turn undone is a truth state variable. Current turn undone is false.
	
	After undoing an action:
		decrease UNDOs remaining by 1;
		now current turn undone is true.
		
	Before undoing an action when UNDOs remaining is less than 1:
		say "[bracket]You have used all of your allotted UNDOs![close bracket][line break]";
		rule fails.
	
	Before undoing an action when current turn undone is true:
		say "[bracket]More than one consecutive UNDO is disallowed.[close bracket][line break]";
		rule fails.
	
	Every turn:
		now current turn undone is false.
		
	UNDOs remaining is a number variable. UNDOs remaining is 3. 
	
	When play begins:
		say "Whew, there's a lot of glass in here! A kid like you could get in a lot of trouble in a place like this. Luckily, you've got [UNDOs remaining in words] chances to UNDO any problems you cause! Be careful, though, as you can only UNDO one turn in a row.";
		now the right hand status line is "UNDOs left: [UNDOs remaining]"
	
	Laboratory is a room.
	
	A glasswork is a kind of thing. A beaker, a pipette, a test tube, and a graduated cylinder are glassworks in the Laboratory.
	
	Attacking a glasswork is reckless behavior. Dropping a glasswork is reckless behavior. Inserting a glasswork into is reckless behavior. Throwing a glasswork at is reckless behavior. Squeezing a glasswork is reckless behavior. Pushing a glasswork is reckless behavior. Pulling a glasswork is reckless behavior. Turning a glasswork is reckless behavior. Swinging a glasswork is reckless behavior. Rubbing a glasswork is reckless behavior. Cutting a glasswork is reckless behavior. Examining a glasswork is reckless behavior.
	
	Instead of reckless behavior:
		say "The [noun] shatters into thousands of pieces.";
		remove the noun from play;
		if the pile of broken glass is in the Laboratory:
			say "[line break]The pile of broken glass is now a bit higher.";
		otherwise:
			say "[line break]The pile of broken glass glints in the light.";
			move the pile of broken glass to the Laboratory.
	
	A pile of broken glass is a thing. Instead of doing anything to the pile of glass, say "Looks dangerous, better keep away."
	
	At 9:05 am:
		say "Without warning, your dad enters the lab. ";
		if broken glass is in the Laboratory:
			say "His eyes dart to the pile of broken glass at your feet.";
			end the story finally saying "You are in deep trouble";
		otherwise:
			say "He looks at each of the glass containers in turn, then smiles when he realizes that you managed to stay in here alone for five whole minutes without breaking a single one.";
			end the story finally saying "You have made your father proud"


Example: ** Purgatory - Illustrates how to suspend and reinstate the saving of undo states. The player is presented with a bottle of poison. If she drinks it, she will die within a certain number of turns. We suspend saving of the undo state on the drinking of the bottle, though, so that the player need type UNDO only once to return to the turn before drinking the poison, no matter how many turns have passed since.

Note that we warn the player before allowing her to save during this purgatorial period--restoring the game would discard the saved undo state and effectively doom the PC to death.

	*: "Purgatory"

	Include Undo Output Control by Erik Temple.
	
	Black Room is a room. There is a bottle of poison in Black Room.
	
	Instead of drinking the bottle of poison:
		now the printed name of the bottle is "empty bottle";
		say "You drink down the poison in a single draught! That probably wasn't very smart.";
		disable saving of undo state.
	
	Every turn when the printed name of the bottle is "empty bottle":
		say "[one of]Your cheeks burn[or]Your teeth hurt[or]Your belly twists[or]Your vision fades[the end][stopping]."
	
	To say the end:
		end the game in death.
	
	Before undoing an action when save undo state is false:
		say "[bracket]Attempting to undo to the moment just before you drank the poison.[close bracket][paragraph break]";
		rule succeeds.
	
	Report undoing an action:
		say "[bold type]";
		say "[Location]" in upper case;
		say "[roman type]";
		say "[line break]";
		say "[bracket]Undone.[close bracket][line break]";
		enable saving of undo state;
		rule succeeds.
		
	Check saving the game when save undo state is false:
		say "Maybe it would be best to UNDO your terrible mistake before saving. Are you sure you want to save now, while you're dying? ";
		if the player consents:
			continue the action;
		otherwise:
			rule fails.
