from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1] / "nvim" / ".config" / "nvim"


class NetrwConfigTest(unittest.TestCase):
    def test_leader_explorer_keeps_netrw_plugin_enabled(self):
        keymaps = (ROOT / "lua" / "config" / "keymaps.lua").read_text(encoding="utf-8")
        lazy_config = (ROOT / "lua" / "config" / "lazy.lua").read_text(encoding="utf-8")

        self.assertIn('map("n", "<leader>e", vim.cmd.Ex', keymaps)
        self.assertNotIn('"netrwPlugin"', lazy_config)


if __name__ == "__main__":
    unittest.main()
