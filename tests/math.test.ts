import { describe, expect, it } from "vitest";
import { greet } from "../src/hello.js";
import { add } from "../src/math.js";

describe("math", () => {
  it("BasicAddition", () => {
    expect(add(2, 3)).toBe(5);
    expect(add(-1, 1)).toBe(0);
  });
});

describe("hello", () => {
  it("Greeting", () => {
    expect(greet()).toBe("Hello, World!");
  });
});
