export function greet(name = "World"): string {
  return `Hello, ${name}!`;
}

console.log(greet());
