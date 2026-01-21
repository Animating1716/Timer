import Foundation

struct StretchExercise: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let symbolName: String
    let imageName: String?

    init(
        id: String,
        name: String,
        description: String,
        symbolName: String,
        imageName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.symbolName = symbolName
        self.imageName = imageName
    }
}

enum StretchCatalog {
    static let exercises: [StretchExercise] = [
        StretchExercise(
            id: "neck-release",
            name: "Nacken-Release",
            description: "Kinn zur Brust, dann sanft nach links und rechts neigen.",
            symbolName: "figure.mind.and.body",
            imageName: "neck_release"
        ),
        StretchExercise(
            id: "shoulder-rolls",
            name: "Schulterkreisen",
            description: "Große Kreise nach hinten, Schultern tief halten.",
            symbolName: "bolt.fill",
            imageName: "shoulder_rolls"
        ),
        StretchExercise(
            id: "chest-opener",
            name: "Brustöffner",
            description: "Hände hinter dem Rücken verschränken und öffnen.",
            symbolName: "heart.fill",
            imageName: "chest_opener"
        ),
        StretchExercise(
            id: "upper-back",
            name: "Oberer Rücken",
            description: "Arme nach vorne strecken, Schulterblätter auseinander.",
            symbolName: "moon.fill",
            imageName: "upper_back"
        ),
        StretchExercise(
            id: "thoracic-rotation",
            name: "Sitzende Rotation",
            description: "Aufrecht sitzen, Oberkörper sanft zur Seite drehen.",
            symbolName: "leaf.fill",
            imageName: "seated_twist"
        ),
        StretchExercise(
            id: "wrist-forearm",
            name: "Handgelenke",
            description: "Handflächen nach vorn, Finger sanft zurückziehen.",
            symbolName: "hand.raised.fill",
            imageName: "wrist_stretch"
        ),
        StretchExercise(
            id: "side-bend",
            name: "Seitbeuge",
            description: "Einen Arm über den Kopf, langsam zur Seite lehnen.",
            symbolName: "figure.mind.and.body",
            imageName: "side_bend"
        ),
        StretchExercise(
            id: "hamstring",
            name: "Beinrückseite",
            description: "Mit geradem Rücken nach vorne beugen, Knie weich.",
            symbolName: "figure.run",
            imageName: "hamstring"
        ),
        StretchExercise(
            id: "hip-flexor",
            name: "Hüftbeuger",
            description: "Ausfallschritt, Becken leicht nach vorne schieben.",
            symbolName: "figure.run",
            imageName: "hip_flexor"
        ),
        StretchExercise(
            id: "glute-seated",
            name: "Sitzender Gesäßstretch",
            description: "Bein über das andere schlagen und nach vorn lehnen.",
            symbolName: "figure.mind.and.body",
            imageName: "glute_seated"
        ),
        StretchExercise(
            id: "calf-stretch",
            name: "Wade",
            description: "Ferse am Boden, Knie gestreckt, leicht nach vorne lehnen.",
            symbolName: "figure.run",
            imageName: "calf_stretch"
        )
    ]

    static func pickExercises(
        count: Int,
        preferences: [String: Int]
    ) -> [StretchExercise] {
        guard count > 0 else { return [] }
        var available = exercises
        var chosen: [StretchExercise] = []
        let target = min(count, available.count)

        for _ in 0..<target {
            let weights = available.map { exercise in
                let bias = preferences[exercise.id] ?? 0
                return max(1, 5 + bias)
            }
            let total = weights.reduce(0, +)
            let roll = Int.random(in: 0..<total)
            var cumulative = 0
            var index = 0
            for (i, weight) in weights.enumerated() {
                cumulative += weight
                if roll < cumulative {
                    index = i
                    break
                }
            }
            chosen.append(available.remove(at: index))
        }

        return chosen
    }

    static func nextExercise(after index: Int) -> (StretchExercise, Int) {
        guard !exercises.isEmpty else {
            return (StretchExercise(id: "none", name: "Dehnung", description: "", symbolName: "figure.mind.and.body"), 0)
        }

        let nextIndex = (index + 1) % exercises.count
        return (exercises[nextIndex], nextIndex)
    }
}
