// Preloaded into stimulus-language-server via NODE_OPTIONS (see lsp_settings.lua).
// stimulus-parser resolves an extensionless relative import with the importing file's extension, so the
// `import X from "./foo_controller"` lines that `rails stimulus:manifest:update` writes into index.js never
// reach foo_controller.ts and every TypeScript controller is reported as invalid.
const fs = require("fs")
const path = require("path")

const extensions = [".ts", ".js", ".mts", ".mjs", ".tsx", ".jsx"]

try {
  const serverDir = path.dirname(fs.realpathSync(process.argv[1]))
  const parserDir = path.dirname(require.resolve("stimulus-parser/package.json", { paths: [serverDir] }))
  const { ImportDeclaration } = require(path.join(parserDir, "dist/import_declaration.js"))
  const original = Object.getOwnPropertyDescriptor(ImportDeclaration.prototype, "resolvedRelativePath")

  Object.defineProperty(ImportDeclaration.prototype, "resolvedRelativePath", {
    ...original,
    get() {
      const resolved = original.get.call(this)
      if (!resolved || path.extname(this.source) || fs.existsSync(resolved)) return resolved

      const base = path.join(path.dirname(this.sourceFile.path), this.source)
      return extensions.map(ext => base + ext).find(candidate => fs.existsSync(candidate)) ?? resolved
    },
  })
} catch (error) {
  process.stderr.write(`stimulus_ls_resolve_ts: patch not applied: ${error.message}\n`)
}
