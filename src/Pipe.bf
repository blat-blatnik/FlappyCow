using SDL2;
using System;

namespace FlappyCow
{
	struct Pipe
	{
		public float X;
		public float TopY;
		public float BottomY;
		public static float Width { get => Texture.PipeMiddle.Width; }
		public const float Speed = 4;

		public void Update() mut
		{
			X -= Speed;
		}

		public void Draw(SDL.Renderer* renderer)
		{
			top:
			{
				float y = TopY - Texture.PipeTop.Height;
				Texture.PipeTop.DrawFlipped(renderer, X, y);

				y -= Texture.PipeMiddle.Height;
				while (y > -Texture.PipeMiddle.Height)
				{
					Texture.PipeMiddle.Draw(renderer, X, y);
					y -= Texture.PipeMiddle.Height;
				}
			}
			bottom:
			{
				Texture.PipeBottom.Draw(renderer, X, Background.FloorY);
				float y = Background.FloorY - Texture.PipeMiddle.Height;
				while (y > BottomY + Texture.PipeMiddle.Height)
				{
					Texture.PipeMiddle.Draw(renderer, X, y);
					y -= Texture.PipeMiddle.Height;
				}
				Texture.PipeTop.Draw(renderer, X, BottomY);
			}
		}

		public SDL.Rect[4] CollisionRects
		{
			get
			{
				const int Rect1OffsetX = 2;
				const int Rect1OffsetY = 10;
				const int Rect1Width = 113 - 2*Rect1OffsetX;
				const int Rect1Height = 55;
				const int Rect2OffsetX = 12;
				const int Rect2Width = 89;

				int32 x1 = (.)X + Rect1OffsetX;
				int32 x2 = (.)X + Rect2OffsetX;

				SDL.Rect[4] rects;
				top:
				{
					int32 y = (.)TopY - Rect1Height - Rect1OffsetY;
					rects[0] = .{ x = x1, y = y, w = Rect1Width, h = Rect1Height };
					rects[1] = .{ x = x2, y = -int16.MaxValue, w = Rect2Width, h = y + int16.MaxValue };
				}
				bottom:
				{
					int32 y = (.)BottomY + Rect1OffsetY;
					rects[2] = .{ x = x1, y = y, w = Rect1Width, h = Rect1Height };
					rects[3] = .{ x = x2, y = y + Rect1Height, w = Rect2Width, h = (.)(Background.FloorY - y - Rect1Height) };
				}

				return rects;
			}
		}
	}
}
