import { defineConfig } from "vitest/config";

/**
 * Configuracion de Vitest para tests unitarios de Cloud Functions.
 * Los tests corren en Node (no jsdom) porque las Cloud Functions no tienen DOM.
 */
export default defineConfig({
  test: {
    environment: "node",
    globals: true,
    include: ["test/**/*.test.ts"],
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      include: ["src/**/*.ts"],
      exclude: ["src/index.ts", "src/config.ts"],
    },
  },
});
