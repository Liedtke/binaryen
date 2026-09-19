import subprocess

from scripts.test import shared

from . import utils


class InitialFuzzTest(utils.BinaryenTestCase):
    def test_empty_initial(self):
        # generate fuzz from random data
        data = self.input_path('random_data.txt')
        a = shared.run_process(shared.WASM_OPT + ['-ttf', '--print', data],
                               stdout=subprocess.PIPE).stdout

        # generate fuzz from random data with initial empty wasm
        empty_wasm = self.input_path('empty.wasm')
        b = shared.run_process(
            shared.WASM_OPT + ['-ttf', '--print', data,
                               '--initial-fuzz=' + empty_wasm],
            stdout=subprocess.PIPE).stdout

        # an empty initial wasm causes no changes
        self.assertEqual(a, b)

    def test_small_initial(self):
        data = self.input_path('random_data.txt')
        hello_wat = self.input_path('hello_world.wat')
        out = shared.run_process(shared.WASM_OPT + ['-ttf', '--print', data,
                                 '--initial-fuzz=' + hello_wat],
                                 stdout=subprocess.PIPE).stdout

        # the function should be there (perhaps with modified contents - don't
        # check that)
        self.assertIn('(export "add" (func $add))', out)

        # there should be other fuzz contents added as well
        self.assertGreater(out.count('(export '), 1)

    def test_replace_contents_requires_preserve(self):
        # --fuzz-replace-contents only makes sense when we are preserving the
        # imports and exports, and must error out otherwise.
        data = self.input_path('random_data.txt')
        hello_wat = self.input_path('hello_world.wat')
        p = shared.run_process(
            shared.WASM_OPT + ['-ttf', '--print', data,
                               '--initial-fuzz=' + hello_wat,
                               '--fuzz-replace-contents'],
            check=False, capture_output=True)
        self.assertNotEqual(p.returncode, 0)
        self.assertIn('--fuzz-replace-contents requires '
                      '--fuzz-preserve-imports-exports', p.stderr)

    def test_replace_contents(self):
        # With --fuzz-replace-contents the public interface must be preserved
        # while everything private is discarded. Run the same input both with
        # and without the flag: the contrast is what makes this meaningful, as
        # it shows the private content really would have survived otherwise.
        data = self.input_path('random_data.txt')
        wat = self.input_path('replace_contents.wat')
        common = shared.WASM_OPT + ['-ttf', '--print', data,
                                    '--initial-fuzz=' + wat,
                                    '--fuzz-preserve-imports-exports']

        kept = shared.run_process(common, stdout=subprocess.PIPE).stdout
        replaced = shared.run_process(common + ['--fuzz-replace-contents'],
                                      stdout=subprocess.PIPE).stdout

        # The export survives either way, and no new exports are added (unlike
        # test_small_initial, which does not preserve the interface).
        for out in [kept, replaced]:
            self.assertIn('(export "kept" (func $kept))', out)
            self.assertEqual(out.count('(export '), 1)

        # Without the flag the private content is still there.
        self.assertIn('$private_helper', kept)
        self.assertIn('$private_global', kept)

        # With it, the private content is gone. Note that $kept referred to
        # both, so this also checks that we do not leave a dangling reference.
        self.assertNotIn('$private_helper', replaced)
        self.assertNotIn('$private_global', replaced)
