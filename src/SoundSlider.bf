using System;

using SDL2;
namespace FlappyCow
{
	struct SoundSlider
	{
		public bool IsActive;
		public float Value;
		public int X;
		public int Y;
		public int Width => Texture.Slider.Width;
		public int Height => Texture.Slider.Height;

		const int IndicatorOffsetX = 32;
		const int IndicatorOffsetY = 5;
		const int IndicatorWidth = 232;
		const int IndicatorHeight = 18;

		public this(float x, float y, float initalValue)
		{
			X = (.)x;
			Y = (.)y;
			Value = Math.Clamp(initalValue, 0, 1);
			IsActive = false;
		}

		public void OnEvent(SDL.Event event) mut
		{
			if (event.type == .MouseButtonDown && event.button.button == SDL.SDL_BUTTON_LEFT)
			{
				int x = event.button.x;
				int y = event.button.y;
				if (x >= X && y >= Y && x < X + Width && y < Y + Height)
				{
					IsActive = true;
					Value = Math.Clamp((x - (X + IndicatorOffsetX)) / (float)IndicatorWidth, 0, 1);
				}
			}
			else if (event.type == .MouseMotion && IsActive)
			{
				int x = event.motion.x;
				Value = Math.Clamp((x - (X + IndicatorOffsetX)) / (float)IndicatorWidth, 0, 1);
			}
			else if (event.type == .MouseButtonUp && event.button.button == SDL.SDL_BUTTON_LEFT && IsActive)
			{
				IsActive = false;
			}
		}

		public void Draw(SDL.Renderer* renderer)
		{
			SDL.Rect indicatorRect = .{
				x = (.)(X + IndicatorOffsetX),
				y = (.)(Y + IndicatorOffsetY),
				w = IndicatorWidth,
				h = IndicatorHeight
			};

			SDL.SetRenderDrawColor(renderer, 51, 27, 11, 255);
			SDL.RenderFillRect(renderer, &indicatorRect);

			indicatorRect.w = (.)(indicatorRect.w * Value);
			SDL.SetRenderDrawColor(renderer, 202, 111, 74, 255);
			SDL.RenderFillRect(renderer, &indicatorRect);

			Texture.Slider.Draw(renderer, X, Y);
		}
	}
}
