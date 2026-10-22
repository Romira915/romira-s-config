import unittest

from filter_toml import filter_toml


class FilterTomlTest(unittest.TestCase):
    def test_runtime_model_settings_are_excluded_but_shared_settings_remain(self):
        lines = [
            'model = "gpt-5.6-luna"\n',
            'model_reasoning_effort = "max"\n',
            'plan_mode_reasoning_effort = "xhigh"\n',
            'service_tier = "default"\n',
            'approvals_reviewer = "user"\n',
        ]

        self.assertEqual(
            filter_toml(lines),
            ['approvals_reviewer = "user"\n'],
        )

    def test_excluded_settings_are_removed_from_both_versions(self):
        head_lines = [
            'model = "gpt-5.6-sol"\n',
            'model_reasoning_effort = "high"\n',
            'approvals_reviewer = "user"\n',
        ]
        current_lines = [
            'model = "gpt-5.6-luna"\n',
            'model_reasoning_effort = "max"\n',
            'approvals_reviewer = "user"\n',
        ]

        self.assertEqual(filter_toml(head_lines), filter_toml(current_lines))

    def test_app_written_local_state_is_excluded_but_table_settings_remain(self):
        lines = [
            '[tui]\n',
            'session_picker_view = "dense"\n',
            'screen_reader_detection_done = true\n',
            '\n',
            '[[skills.config]]\n',
            'path = "/Users/example/.codex/skills/sample/SKILL.md"\n',
            'enabled = false\n',
            '\n',
            '[plugins."code-review@openai-bundled"]\n',
            'enabled = true\n',
        ]

        self.assertEqual(
            filter_toml(lines),
            [
                '[tui]\n',
                'session_picker_view = "dense"\n',
                '\n',
                '[plugins."code-review@openai-bundled"]\n',
                'enabled = true\n',
            ],
        )


if __name__ == "__main__":
    unittest.main()
