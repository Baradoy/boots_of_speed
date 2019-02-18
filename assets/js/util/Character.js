export function objectToArray(characters) {
  return Object.keys(characters).map(key => ({
    name: key,
    ...characters[key]
  }));
}

export function minus(minuendCharacters, subtrahendCharacters) {
  return minuendCharacters.filter(
    minuend =>
      !subtrahendCharacters.find(subtrahend => subtrahend.name === minuend.name)
  );
}
