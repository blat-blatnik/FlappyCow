using SDL2;
using System;
using System.Diagnostics;
using System.IO;
using System.Collections;

namespace FlappyCow
{
	class Game : SDLApp
	{
		public const int Width = 540;
		public const int Height = 720;
		public const String Title = "Flappy Cow";
		public const float ScoreX = Width / 2;
		public const float ScoreY = Height / 5;

		Stopwatch youGotPointsAnimationTime = new .() ~ delete _;
		Stopwatch scoreboardDropAnimationTime = new .() ~ delete _;
		bool initialized;
		GameState gameState;
		int score = 0;
		int64 bestScore = 0;
		Cow cow ~ delete _;
		PipeManager pipeManager ~ delete _;
		DrawString scoreString ~ delete _;
		DrawString bestScoreString ~ delete _;
		Background background;
		SoundSlider volumeSlider = SoundSlider(123, 674, 1);

		struct SaveFileData
		{
			public int64 bestScore;
			public float volume;
		}

		public this() : base()
		{
			delete mTitle;
			mTitle = new .(Title);
			mWidth = Width;
			mHeight = Height;
		}

		public override void Update()
		{
			base.Update();
			InitializeIfNotAlreadyInitialized();

			if (volumeSlider.Value != Audio.GlobalVolume)
			{
				Audio.GlobalVolume = volumeSlider.Value;
				SaveData();
			}

			if (cow.IsAlive)
			{
				if (gameState == .Playing)
				{
					int scoreIncrement = pipeManager.Update(cow);
					if (scoreIncrement > 0)
					{
						int oldScore = score;
						score += scoreIncrement;
						int newScore = score;
						bool isHighscore = oldScore <= bestScore && newScore > bestScore;

						Audio.ScorePoint.Play();
						youGotPointsAnimationTime.Restart();

						if (isHighscore)
						{
							ParticleEmmiter.Emit(
								0,
								1.5f,
								500,
								ScoreX,
								ScoreY,
								2,
								0,
								0,
								200,
								SDL.Color(253, 55, 140, 255),
								SDL.Color(21, 190, 249, 255),
								SDL.Color(229, 194, 50, 255),
								SDL.Color(68, 182, 71, 255));
						}
						else
						{
							ParticleEmmiter.Emit(
								0,
								1.0f,
								100,
								ScoreX,
								ScoreY,
								2,
								0,
								0,
								100,
								SDL.Color(255, 255, 255, 255));
						}
					}
				}
				background.Update();
			}

			bool wasAlive = cow.IsAlive;
			cow.Update(pipeManager.Pipes, gameState == .WarmUp);
			if (wasAlive && !cow.IsAlive)
			{
				gameState = .GameOver;
				scoreboardDropAnimationTime.Restart();

				if (score > bestScore)
				{
					bestScore = score;
					SaveData();
				}
			}

			ParticleEmmiter.Update();
		}

		public override void Draw()
		{
			base.Draw();
			InitializeIfNotAlreadyInitialized();

			background.Draw(mRenderer);
			pipeManager.Draw(mRenderer);
			ParticleEmmiter.Draw(mRenderer);
			cow.Draw(mRenderer);

			if (gameState == .WarmUp)
				volumeSlider.Draw(mRenderer);

			var newScoreString = scope $"{score}";

			if (cow.IsAlive)
			{
				float t = (.)youGotPointsAnimationTime.ElapsedSeconds;
				const float AnimationLength = 0.15f;
				if (t < AnimationLength)
					scoreString.Draw(newScoreString, ScoreX, ScoreY, Math.SmoothStep(1, 2, t / AnimationLength));
				else
					scoreString.Draw(newScoreString, ScoreX, ScoreY, Math.SmoothStep(2, 1, (t - AnimationLength) / AnimationLength));
			}
			else
			{
				float x = 95;
				float y = ScoreboardY;

				Texture.Scoreboard.Draw(mRenderer, x, y);

				const float ScoreOffsetX = 250;
				const float ScoreOffsetY = 230;
				const float BestOffsetX = 250;
				const float BestOffsetY = 330;

				var bestScoreString = scope $"{bestScore}";
				scoreString.Draw(newScoreString, x + ScoreOffsetX, y + ScoreOffsetY);
				scoreString.Draw(bestScoreString, x + BestOffsetX, y + BestOffsetY);
			}
		}

		public override void KeyDown(SDL.KeyboardEvent evt)
		{
			base.KeyDown(evt);
			InitializeIfNotAlreadyInitialized();

			let keycode = evt.keysym.sym;
			switch (keycode)
			{
			case .ESCAPE:
				SDL.Event e = .{ type = .Quit };
				SDL.PushEvent(ref e);
			case .SPACE: fallthrough;
			case .RETURN: fallthrough;
			case .UP: fallthrough;
			case .W:
				if (gameState == .WarmUp)
					gameState = .Playing;
				if (gameState == .Playing)
					cow.Flap();
				if (gameState == .GameOver && ScoreboardY > -Texture.Scoreboard.Height / 2)
					NewGame(); // TODO:
			case .R:
				NewGame();
			default:
			}
		}

		public override void HandleEvent(SDL.Event event)
		{
			base.HandleEvent(event);
			volumeSlider.OnEvent(event);
		}

		public override void MouseDown(SDL.MouseButtonEvent event)
		{
			base.MouseDown(event);
			InitializeIfNotAlreadyInitialized();

			SDL.Event e = .{ type = .MouseButtonDown, button = event };
			volumeSlider.OnEvent(e);

			if (volumeSlider.IsActive)
				return;

			if (cow.IsAlive)
			{
				if (gameState == .WarmUp)
					gameState = .Playing;
				if (gameState == .Playing)
					cow.Flap();
			}
			else
			{
				const float Extension = 6;
				const float RestartButtonHeight = 89;
				SDL.Rect restartRect = .{
					x = (.)(ScoreboardX - Extension),
					y = (.)(ScoreboardY + Texture.Scoreboard.Height - RestartButtonHeight - Extension),
					w = (.)(Texture.Scoreboard.Width + 2 * Extension),
					h = (.)(RestartButtonHeight + 2 * Extension)
				};

				SDL.Point p = .(event.x, event.y);
				if (SDL.PointInRect(&p, &restartRect))
				{
					NewGame();
				}
			}
		}

		const float ScoreboardX = 95;
		float ScoreboardY
		{
			get
			{
				const float AnimationDelay = 0.3f;
				const float AnimationLength = 0.5f;
				float t = (.)scoreboardDropAnimationTime.ElapsedSeconds - AnimationDelay;

				float y0 = -Texture.Scoreboard.Height;
				float y1 = 0;
				return Math.SmoothStep(y0, y1, t / AnimationLength);
			}
		}

		void GetSaveFilePath(String buffer)
		{
			char8 *saveDirectoryPathPtr = SDL.GetPrefPath("Blatnik", "Flappy Cow");
			defer SDL.free(saveDirectoryPathPtr);
			StringView saveDirectoryPath = .(saveDirectoryPathPtr);
			buffer.Append(scope $"{saveDirectoryPath}highscore.bin");
		}

		void InitializeIfNotAlreadyInitialized()
		{
			if (initialized)
				return;
			initialized = true;

			SDL.SetRenderDrawBlendMode(mRenderer, .Blend);

			String saveFilePath = scope .();
			GetSaveFilePath(saveFilePath);
			if (File.Exists(saveFilePath))
			{
				List<uint8> bytes = scope .(sizeof(SaveFileData));
				if (File.ReadAll(saveFilePath, bytes) case .Ok)
				{
					SaveFileData data = *(SaveFileData *)&bytes[0];
					Audio.GlobalVolume = data.volume;
					bestScore = data.bestScore;
				}
			}

			Audio.LoadAll(); // We don't actually _need_ to load the audio until the game starts - we can do this on a separate thread.
			Texture.LoadAll();
			Fonts.LoadAll(); // We don't actually _need_ to load this until the game starts - we can do this on a separate thread.
			scoreString = new DrawString(Fonts.Big, mRenderer, "", .(255, 255, 255, 255));
			bestScoreString = new DrawString(Fonts.Big, mRenderer, "", .(255, 255, 255, 255));
			background = Background();
			volumeSlider.Value = Audio.GlobalVolume;
			NewGame();
		}

		void SaveData()
		{
			String saveFilePath = scope .();
			GetSaveFilePath(saveFilePath);

			SaveFileData data = .{
				bestScore = bestScore,
				volume = volumeSlider.Value
			};

			File.WriteAll(saveFilePath, .((uint8*)&data, sizeof(SaveFileData)));
		}

		void NewGame()
		{
			delete cow;
			delete pipeManager;
			Audio.StopAll();
			cow = new Cow();
			pipeManager = new PipeManager();
			background = Background();
			ParticleEmmiter.Clear();
			score = 0;
			gameState = .WarmUp;
		}

		enum GameState
		{
			case WarmUp;
			case Playing;
			case GameOver;
		}
	}
}
