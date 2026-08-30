import unittest
from pathlib import Path

from mng import first_png_frame, parse

FIXTURES = Path(__file__).resolve().parents[1] / "tests" / "fixtures"

def fixture(name: str) -> bytes:
    return bytes.fromhex((FIXTURES / name).read_text())

class MNGTests(unittest.TestCase):
    def test_single_frame(self):
        animation = parse(fixture("minimal-1x1.mng.hex"))
        self.assertEqual((animation.width, animation.height), (1, 1))
        self.assertEqual(len(animation.frames), 1)
        self.assertEqual(animation.frames[0].delay_milliseconds, 100)
        self.assertTrue(first_png_frame(fixture("minimal-1x1.mng.hex")).startswith(b"\x89PNG"))

    def test_timed_frames(self):
        animation = parse(fixture("timed-2-frame.mng.hex"))
        self.assertEqual([frame.delay_milliseconds for frame in animation.frames], [250, 500])
        self.assertEqual(animation.frame_index_at(0), 0)
        self.assertEqual(animation.frame_index_at(250), 1)
        self.assertEqual(animation.frame_index_at(750), 0)

if __name__ == "__main__":
    unittest.main()
