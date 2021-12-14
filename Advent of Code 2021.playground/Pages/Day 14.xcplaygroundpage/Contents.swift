import Foundation
//: [Previous](@previous)
/*:
 ## Day 14: Extended Polymerization

 ### Part One

 The incredible pressures at this depth are starting to put a strain on your submarine. The submarine has polymerization equipment that would produce suitable materials to reinforce the submarine, and the nearby volcanically-active caves should even have the necessary input elements in sufficient quantities.

 The submarine manual contains instructions for finding the optimal polymer formula; specifically, it offers a polymer template and a list of pair insertion rules (your puzzle input). You just need to work out what polymer would result after repeating the pair insertion process a few times.

 For example:

     NNCB

     CH -> B
     HH -> N
     CB -> H
     NH -> C
     HB -> C
     HC -> B
     HN -> C
     NN -> C
     BH -> H
     NC -> B
     NB -> B
     BN -> B
     BB -> N
     BC -> B
     CC -> N
     CN -> C

 The first line is the polymer template - this is the starting point of the process.

 The following section defines the pair insertion rules. `A` rule like `AB -> C` means that when elements `A` and `B` are immediately adjacent, element `C` should be inserted between them. These insertions all happen simultaneously.

 So, starting with the polymer template `NNCB`, the first step simultaneously considers all three pairs:

 - The first pair (`NN`) matches the rule `NN -> C`, so element `C` is inserted between the first `N` and the second `N`.
 - The second pair (`NC`) matches the rule `NC -> B`, so element `B` is inserted between the `N` and the `C`.
 - The third pair (`CB`) matches the rule `CB -> H`, so element `H` is inserted between the `C` and the `B`.

 Note that these pairs overlap: the second element of one pair is the first element of the next pair. Also, because all pairs are considered simultaneously, inserted elements are not considered to be part of a pair until the next step.

 After the first step of this process, the polymer becomes `NCNBCHB`.

 Here are the results of a few steps using the above rules:

     Template:     NNCB
     After step 1: NCNBCHB
     After step 2: NBCCNBBBCBHCB
     After step 3: NBBBCNCCNBBNBNBBCHBHHBCHB
     After step 4: NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB

 This polymer grows quickly. After step 5, it has length 97; After step 10, it has length 3073. After step 10, `B` occurs 1749 times, `C` occurs 298 times, `H` occurs 161 times, and `N` occurs 865 times; taking the quantity of the most common element (`B`, 1749) and subtracting the quantity of the least common element (`H`, 161) produces `1749 - 161 = 1588`.

 Apply 10 steps of pair insertion to the polymer template and find the most and least common elements in the result. What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?
 */

let input = try Input.day14.load(as: [String].self)
let polymerTemplate = input[0]
let pairInsertionRules = Dictionary(uniqueKeysWithValues: input.dropFirst().map { line -> (Pair, Character) in
    let components = line.split(whereSeparator: { $0 == " " || $0 == "-" || $0 == ">" })
    return (Pair(components[0]), components[1].first!)
})

func recursiveExpandPair(
    _ pair: Pair,
    times step: Int,
    expansionRules: [Pair: Character],
    cache: inout [Pair: [Int: [Character: UInt]]]
) -> [Character: UInt] {
    if step == 0 {
        var counters: [Character: UInt] = [:]
        counters[pair.first, default: 0] += 1
        counters[pair.second, default: 0] += 1
        return counters
    }

    let expandPair = { (times: Int, pair: Pair, cache: inout [Pair: [Int: [Character: UInt]]]) -> [Character: UInt] in
        if let cached = cache[pair]?[step] {
            return cached
        } else {
            let result = recursiveExpandPair(pair, times: times, expansionRules: expansionRules, cache: &cache)
            cache[pair, default: [:]][step] = result
            return result
        }
    }

    let element = expansionRules[pair]!
    let (first, second) = pair.pairsInserting(element)
    var counter = expandPair(step - 1, first, &cache)
    counter.merge(expandPair(step - 1, second, &cache), uniquingKeysWith: +)
    counter[element]? -= 1

    return counter
}

func solve(steps: Int, polymerTemplate: String, expansionRules: [Pair: Character]) -> UInt {
    var counters: [Character: UInt] = [:]
    var cache: [Pair: [Int: [Character: UInt]]] = [:]
    for pair in polymerTemplate.pairs() {
        counters[pair.first]? -= 1

        let pairCounters = recursiveExpandPair(pair, times: steps, expansionRules: expansionRules, cache: &cache)
        counters.merge(pairCounters, uniquingKeysWith: +)
    }

    return counters.values.max()! - counters.values.min()!
}

let answer1 = solve(steps: 10, polymerTemplate: polymerTemplate, expansionRules: pairInsertionRules)
answer1

/*:
 ### Part Two

 The resulting polymer isn't nearly strong enough to reinforce the submarine. You'll need to run more steps of the pair insertion process; a total of 40 steps should do it.

 In the above example, the most common element is `B` (occurring `2192039569602` times) and the least common element is `H` (occurring `3849876073` times); subtracting these produces `2188189693529`.

 Apply 40 steps of pair insertion to the polymer template and find the most and least common elements in the result. What do you get if you take the quantity of the most common element and subtract the quantity of the least common element?
 */

let answer2 = solve(steps: 40, polymerTemplate: polymerTemplate, expansionRules: pairInsertionRules)
answer2

//: [Next](@next)
