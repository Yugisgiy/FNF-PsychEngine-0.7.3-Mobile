package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		//#if MODS_ALLOWED 'mods', #end
		//#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		//#if !switch 'donate', #end
		'options'
	];

	var char:FlxSprite;
	var backdrop:FlxBackdrop;

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var theBG:BGSprite = new BGSprite('greenfarm', -680, -130, 0, 0);
		add(theBG);
		

		backdrop = new FlxBackdrop(Paths.image('backd'), XY, 0, 0);
		backdrop.velocity.set(200, 110);
		backdrop.updateHitbox();
		backdrop.alpha = 0.5;
		backdrop.screenCenter(X);
		add(backdrop);

		var bga:FlxSprite = new FlxSprite(-120).loadGraphic(Paths.image('bgthing'));
		bga.setGraphicSize(Std.int(bg.width * 1.175));
		bga.updateHitbox();
		bga.screenCenter();
		bga.antialiasing = ClientPrefs.globalAntialiasing;
		add(bga);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		//magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
			menuItem.x += 300;
		}

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Strident Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		var watermarkMenuTxt:FlxText = new FlxText(12, FlxG.height - 64, 0, "Strident Crisis V1.5", 12);
		watermarkMenuTxt.scrollFactor.set();
		watermarkMenuTxt.setFormat("Comic Sans MS", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(watermarkMenuTxt);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		addTouchPad("UP_DOWN", "A_B");

		super.create();

		//FlxG.camera.follow(camFollow, null, 9);

		switch (FlxG.random.int(1, 6))
		{
			case 1:
				char = new FlxSprite(100, 270).loadGraphic(Paths.image('mainmenu/bambiRemake'));//put your cords and image here
				char.frames = Paths.getSparrowAtlas('mainmenu/bambiRemake');//here put the name of the xml
				char.animation.addByPrefix('idleR', 'bambi idle', 24, true);//on 'idle normal' change it to your xml one
				char.animation.play('idleR');//you can rename the anim however you want to
				char.scrollFactor.set();
				add(char);
			case 2:
				char = new FlxSprite(-700, -170).loadGraphic(Paths.image('mainmenu/Bamb'));//put your cords and image here
				char.frames = Paths.getSparrowAtlas('mainmenu/Bamb');//here put the name of the xml
				char.animation.addByPrefix('idleR', 'Bamb Idle', 24, true);//on 'idle normal' change it to your xml one
				char.animation.play('idleR');//you can rename the anim however you want to
				char.scrollFactor.set();
				char.scale.set(0.6, 0.6);
				add(char);
			case 3:
				char = new FlxSprite(-100, 120).loadGraphic(Paths.image('mainmenu/Banbi'));//put your cords and image here
				char.frames = Paths.getSparrowAtlas('mainmenu/Banbi');//here put the name of the xml
				char.animation.addByPrefix('idleR', 'Banbi Idle', 24, true);//on 'idle normal' change it to your xml one
				char.animation.play('idleR');//you can rename the anim however you want to
				char.scrollFactor.set();
				char.scale.set(0.7, 0.7);
				add(char);

				case 4:
					char = new FlxSprite(100, 140).loadGraphic(Paths.image('mainmenu/OppositionX_Assets'));//put your cords and image here
					char.frames = Paths.getSparrowAtlas('mainmenu/OppositionX_Assets');//here put the name of the xml
					char.animation.addByPrefix('idleR', 'Idle', 24, true);//on 'idle normal' change it to your xml one
					char.animation.play('idleR');//you can rename the anim however you want to
					char.scrollFactor.set();
					char.scale.set(1.5, 1.5);
					add(char);

					case 5:
						char = new FlxSprite(50, -80).loadGraphic(Paths.image('mainmenu/Cheater'));//put your cords and image here
						char.frames = Paths.getSparrowAtlas('mainmenu/Cheater');//here put the name of the xml
						char.animation.addByPrefix('idleR', 'Cheater Idle', 24, true);//on 'idle normal' change it to your xml one
						char.animation.play('idleR');//you can rename the anim however you want to
						char.scrollFactor.set();
						char.scale.set(0.7, 0.7);
						add(char);
					case 6:
						char = new FlxSprite(-300, -170).loadGraphic(Paths.image('mainmenu/diambi'));//put your cords and image here
						char.frames = Paths.getSparrowAtlas('mainmenu/diambi');//here put the name of the xml
						char.animation.addByPrefix('idleR', 'diambi idle', 24, true);//on 'idle normal' change it to your xml one
						char.animation.play('idleR');//you can rename the anim however you want to
						char.scrollFactor.set();
						char.scale.set(0.7, 0.7);
						add(char);
					    

		}
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;

					if (ClientPrefs.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
					{

					menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
																FlxTween.tween(char, {x: -700}, 2, {ease: FlxEase.backInOut, type: ONESHOT, onComplete: function(twn:FlxTween) {
									char.kill(); /*I killed the char*/
								}});
								FlxTween.tween(spr, {x: 1200}, 2, {ease: FlxEase.backInOut, type: ONESHOT, onComplete: function(twn:FlxTween) {
									spr.kill(); /*Mom I killed the sprs again*/
								}});
								FlxTween.tween(spr, {alpha: 0}, 1.3, {ease: FlxEase.backInOut, type: ONESHOT, onComplete: function(twn:FlxTween){
									spr.kill(); /*Mom I killed the sprs again*/
								}});
							}
							else
							{

						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)

						{
																	   
						switch (optionShit[curSelected])
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());

							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end

							#if ACHIEVEMENTS_ALLOWED
							case 'awards':
								MusicBeatState.switchState(new AchievementsMenuState());
							#end

							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
						}
					});

					for (i in 0...menuItems.members.length)
					{
						if (i == curSelected)
							continue;
						FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								menuItems.members[i].kill();
							}
						});
					}
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		
		menuItems.members[curSelected].animation.play('idle');
		menuItems.offset[curSelected].y = 0;
		menuItems.members[curSelected].updateHitbox();

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		camFollow.setPosition[curSelected](menuItems.getGraphicMidpoint().x, menuItems.getGraphicMidpoint().y);
		menuItems.offset[curSelected].x = 0.15 * (menuItems.frameWidth / 2 + 180);
		menuItems.offset[curSelected].y = 0.15 * menuItems.frameHeight;
		FlxG.log[curSelected].add(menuItems.frameWidth);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
	}
}
