"""Offline ownership and link contracts for the family-local provider pages."""
from pathlib import Path
import re
import unittest
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
FAMILIES = (
    'emma', 'fronius', 'growatt-aggregate', 'luna', 'outback',
    'sdongle', 'smartlogger', 'sun2000',
)
PAGES = tuple(f'architecture/{family}-provider-port.md' for family in FAMILIES)
LINK = re.compile(r'\]\(([^)]+)\)')
DOCS_PREFIX = 'https://github.com/Project-Helianthus/helianthus-docs-modbus/blob/main/'


def owner_links(text):
    return [target for target in LINK.findall(text) if target.endswith('-provider-port.md')]


def broken_targets(text, page, root):
    broken = []
    for target in LINK.findall(text):
        if target.startswith(DOCS_PREFIX):
            path = root / unquote(urlsplit(target).path.split('/blob/main/', 1)[1])
        elif not urlsplit(target).scheme and not target.startswith('#'):
            path = page.parent / unquote(urlsplit(target).path)
        else:
            continue
        if not path.resolve().is_relative_to(root.resolve()) or not path.is_file():
            broken.append(target)
    return broken


class ProviderPortOwnershipTests(unittest.TestCase):
    def test_index_has_exactly_the_eight_local_owners(self):
        self.assertCountEqual(owner_links((ROOT / 'README.md').read_text()), PAGES)
        self.assertEqual(set(PAGES), {
            str(path.relative_to(ROOT))
            for path in (ROOT / 'architecture').glob('*-provider-port.md')
        })

    def test_each_page_claims_documentation_ownership(self):
        for name in PAGES:
            with self.subTest(page=name):
                text = (ROOT / name).read_text()
                self.assertIn('canonical provider-port page in `helianthus-docs-modbus`', text)
                self.assertNotIn('merge hold', text.lower())
                self.assertIn('qualification', text.lower())
                self.assertIn('retain', text.lower())
                self.assertIn('eBUS MCP', text)
                self.assertIn('GraphQL', text)

    def test_all_owned_document_links_resolve_offline(self):
        for name in ('README.md', *PAGES):
            with self.subTest(page=name):
                page = ROOT / name
                self.assertEqual(broken_targets(page.read_text(), page, ROOT), [])

    def test_emma_documents_the_merged_surface(self):
        text = (ROOT / PAGES[0]).read_text()
        code = '\n'.join(re.findall(r'```go\n(.*?)```', text, re.S))
        for declaration in (
            'type I19EmmaProviderPort interface',
            'type I19EmmaProviderConfig struct',
            'I19Refresh(context.Context, EmmaIdentityContext, bool) (EmmaIdentityResult, error)',
            'I19SetContext(EmmaIdentityContext) error',
            'I19Retire()', 'I19Latest() EmmaIdentityResult',
            'I19Identity() (EmmaIdentityInput, bool)',
            'I19RetainedIdentity() (EmmaRetainedIdentity, bool)',
            'func I19NewEmmaProvider(current EmmaIdentityContext, config I19EmmaProviderConfig) (*I19EmmaProvider, error)',
        ):
            with self.subTest(declaration=declaration):
                self.assertIn(declaration, code)
        for obsolete in ('I19EmmaAdapter', 'I19NewEmmaAdapter', 'I19Cancel', 'I19Epoch', 'I19RetainedView'):
            with self.subTest(obsolete=obsolete):
                self.assertNotIn(obsolete, code)
        self.assertIn('The concrete `I19EmmaProvider`', text)

    def test_changed_ownership_target_is_detected(self):
        original = (ROOT / 'README.md').read_text()
        for replacement in (
            'architecture/unknown-provider-port.md',
            '../architecture/emma-provider-port.md',
            'https://github.com/Project-Helianthus/helianthus-modbusreg/blob/main/docs/emma-provider-port.md',
        ):
            with self.subTest(target=replacement):
                changed = original.replace(PAGES[0], replacement)
                self.assertNotEqual(sorted(owner_links(changed)), sorted(PAGES))

    def test_broken_or_escaping_local_link_is_detected(self):
        for target in ('missing-document.md', '../../outside-document.md'):
            with self.subTest(target=target):
                self.assertEqual(
                    broken_targets(f'[contract]({target})', ROOT / PAGES[0], ROOT),
                    [target],
                )


if __name__ == '__main__':
    unittest.main()
