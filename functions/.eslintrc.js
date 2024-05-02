module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "google",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: ["tsconfig.json", "tsconfig.dev.json"],
    sourceType: "module",
  },
  ignorePatterns: [
    "/lib/**/*", // Ignore built files.
  ],
  plugins: [
    "@typescript-eslint",
    "import",
  ],
  rules: {
      "max-len": 0,
      "prefer-const": 0,
      "require-jsdoc": 0,
      "@typescript-eslint/no-var-requires": 0,
      "@typescript-eslint/no-explicit-any": 0,
      "padded-blocks": 0,
      "spaced-comment": 0,
      "no-trailing-spaces": 0,
      "no-multiple-empty-lines": 0,
      "quotes": 0,
      "import/no-unresolved": 0,
      "indent": 0,
      "keyword-spacing": 0,
      "space-before-blocks": 0,
      "brace-style": 0,
      "arrow-parens": 0,
      "comma-dangle": 0,
      "object-curly-spacing": 0,
  },
};
