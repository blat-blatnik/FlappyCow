using SDL2;
using System;
using System.Collections;

namespace FlappyCow
{
	struct Audio : IDisposable
	{
		public static Audio Flap;
		public static Audio CowSplat;
		public static Audio BeefSplat;
		public static Audio ScorePoint;
		public static List<Audio> AllAudio = new .() ~ DeleteContainerAndDisposeItems!(_);

		public static void LoadAll()
		{
			Flap = .("flap.wav");
			CowSplat = .("cow-splat.wav");
			BeefSplat = .("beef-splat.wav");
			ScorePoint = .("score-point.wav");

			AllAudio.Add(Flap);
			AllAudio.Add(CowSplat);
			AllAudio.Add(BeefSplat);
			AllAudio.Add(ScorePoint);
		}

		public static void StopAll()
		{
			for (var audio in ref AllAudio)
				audio.Stop();
		}

		static float globalVolume = 1;
		public static float GlobalVolume
		{
			get => globalVolume;
			set
			{
				if (value == globalVolume)
					return;
				globalVolume = Math.Clamp(value, 0, 1);
				int32 volume = (.)(globalVolume * SDLMixer.MIX_MAX_VOLUME);
				SDLMixer.Volume(-1, volume);
			}
		}

		public SDLMixer.Chunk* Chunk;
		public int32 GroupTag;
		public static int32 NextGroupTag = 0;

		public this(StringView filename)
		{
			String path = scope $"sounds/{filename}";
			Chunk = SDLMixer.LoadWAV(path);
			GroupTag = ++NextGroupTag;
		}

		public void Play() mut
		{
			int32 channel = SDLMixer.PlayChannel(-1, Chunk, 0);
			SDLMixer.GroupChannel(channel, GroupTag);
			//SDLMixer.Volume(channel, (int32)(volume * 128));
		}

		public void Stop() mut
		{
			SDLMixer.HaltGroup(GroupTag);
		}

		public void Dispose()
		{
			SDLMixer.FreeChunk(Chunk);
		}
	}
}
