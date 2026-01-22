import Foundation

struct StretchExercise: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let symbolName: String
    let imageName: String?
    let invertImage: Bool

    init(
        id: String,
        name: String,
        description: String,
        symbolName: String,
        imageName: String? = nil,
        invertImage: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.symbolName = symbolName
        self.imageName = imageName
        self.invertImage = invertImage
    }
}

enum StretchCatalogKind: String, Codable, CaseIterable {
    case legacy = "legacy"
    case lifehack = "lifehack"

    var displayName: String {
        switch self {
        case .legacy:
            return "Klassisch"
        case .lifehack:
            return "Yoga-Guide"
        }
    }

    var detailText: String {
        switch self {
        case .legacy:
            return "Bisheriger Katalog mit kurzen Standard-Dehnungen."
        case .lifehack:
            return "Neue Yoga-Dehnungen mit Bildern aus dem Encyclopedia-Katalog."
        }
    }
}

enum StretchCatalog {
    static let legacyExercises: [StretchExercise] = [
        StretchExercise(
            id: "neck-release",
            name: "Nacken-Release",
            description: "Kinn zur Brust, dann sanft nach links und rechts neigen.",
            symbolName: "figure.mind.and.body",
            imageName: "neck_release",
            invertImage: true
        ),
        StretchExercise(
            id: "shoulder-rolls",
            name: "Schulterkreisen",
            description: "Große Kreise nach hinten, Schultern tief halten.",
            symbolName: "bolt.fill",
            imageName: "shoulder_rolls",
            invertImage: true
        ),
        StretchExercise(
            id: "chest-opener",
            name: "Brustöffner",
            description: "Hände hinter dem Rücken verschränken und öffnen.",
            symbolName: "heart.fill",
            imageName: "chest_opener",
            invertImage: true
        ),
        StretchExercise(
            id: "upper-back",
            name: "Oberer Rücken",
            description: "Arme nach vorne strecken, Schulterblätter auseinander.",
            symbolName: "moon.fill",
            imageName: "upper_back",
            invertImage: true
        ),
        StretchExercise(
            id: "thoracic-rotation",
            name: "Sitzende Rotation",
            description: "Aufrecht sitzen, Oberkörper sanft zur Seite drehen.",
            symbolName: "leaf.fill",
            imageName: "seated_twist",
            invertImage: true
        ),
        StretchExercise(
            id: "wrist-forearm",
            name: "Handgelenke",
            description: "Handflächen nach vorn, Finger sanft zurückziehen.",
            symbolName: "hand.raised.fill",
            imageName: "wrist_stretch",
            invertImage: true
        ),
        StretchExercise(
            id: "side-bend",
            name: "Seitbeuge",
            description: "Einen Arm über den Kopf, langsam zur Seite lehnen.",
            symbolName: "figure.mind.and.body",
            imageName: "side_bend",
            invertImage: true
        ),
        StretchExercise(
            id: "hamstring",
            name: "Beinrückseite",
            description: "Mit geradem Rücken nach vorne beugen, Knie weich.",
            symbolName: "figure.run",
            imageName: "hamstring",
            invertImage: true
        ),
        StretchExercise(
            id: "hip-flexor",
            name: "Hüftbeuger",
            description: "Ausfallschritt, Becken leicht nach vorne schieben.",
            symbolName: "figure.run",
            imageName: "hip_flexor",
            invertImage: true
        ),
        StretchExercise(
            id: "glute-seated",
            name: "Sitzender Gesäßstretch",
            description: "Bein über das andere schlagen und nach vorn lehnen.",
            symbolName: "figure.mind.and.body",
            imageName: "glute_seated",
            invertImage: true
        ),
        StretchExercise(
            id: "calf-stretch",
            name: "Wade",
            description: "Ferse am Boden, Knie gestreckt, leicht nach vorne lehnen.",
            symbolName: "figure.run",
            imageName: "calf_stretch",
            invertImage: true
        )
    ]

    static let lifehackExercises: [StretchExercise] = [
        StretchExercise(
            id: "camel",
            name: "Kamel",
            description: "Knie dich hin, Hände an die Fersen, Brust öffnen, Hüfte nach vorn.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_01_camel_pose"
        ),
        StretchExercise(
            id: "wide-forward-fold",
            name: "Breite Vorbeuge",
            description: "Breit stehen, Rücken lang, aus der Hüfte nach vorn beugen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_02_wide_forward_fold"
        ),
        StretchExercise(
            id: "frog-pose",
            name: "Frosch",
            description: "Knie weit, Unterarme am Boden, Hüfte nach hinten sinken lassen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_03_frog_pose"
        ),
        StretchExercise(
            id: "wide-side-lunge",
            name: "Breite Seitbeuge",
            description: "Breit stehen, in ein Bein sinken, anderes lang strecken.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_04_wide_side_lunge"
        ),
        StretchExercise(
            id: "butterfly-stretch",
            name: "Schmetterling",
            description: "Sitzend Fußsohlen zusammen, Knie nach außen sinken lassen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_05_butterfly_stretch"
        ),
        StretchExercise(
            id: "forearm-extensor-1",
            name: "Unterarm-Extensor",
            description: "Arm strecken, Handfläche nach unten, Finger sanft zu dir ziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_06_forearm_extensor"
        ),
        StretchExercise(
            id: "neck-side-flexion",
            name: "Nacken-Seitneigung",
            description: "Kopf zur Seite neigen, Schultern entspannt lassen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_07_neck_side_flexion"
        ),
        StretchExercise(
            id: "neck-rotation",
            name: "Nacken-Rotation",
            description: "Kopf langsam nach links und rechts drehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_08_neck_rotation"
        ),
        StretchExercise(
            id: "neck-extension",
            name: "Nacken-Streckung",
            description: "Kopf sanft nach hinten, Blick nach oben.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_09_neck_extension"
        ),
        StretchExercise(
            id: "neck-side-flexion-assisted",
            name: "Nacken-Seitneigung (mit Hand)",
            description: "Kopf zur Seite neigen, Hand zieht leicht nach.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_10_neck_side_flexion_assisted"
        ),
        StretchExercise(
            id: "half-kneeling-hip-flexor",
            name: "Kniender Hüftbeuger",
            description: "Halb kniend, Becken nach vorn, Gesäß anspannen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_11_half_kneeling_hip_flexor"
        ),
        StretchExercise(
            id: "lateral-shoulder",
            name: "Seitlicher Schulterstretch",
            description: "Arm vor die Brust, mit der anderen Hand näher ziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_13_lateral_shoulder"
        ),
        StretchExercise(
            id: "standing-neck-flexion",
            name: "Nacken-Beuge im Stand",
            description: "Kopf nach vorn, Hände sanft nach unten drücken.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_14_standing_neck_flexion"
        ),
        StretchExercise(
            id: "lat-wall",
            name: "Lat-Stretch an der Wand",
            description: "Hände an die Wand, Hüfte zurück, Brust Richtung Boden.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_16_lat_wall"
        ),
        StretchExercise(
            id: "childs-pose",
            name: "Kindhaltung",
            description: "Gesäß auf die Fersen, Arme lang nach vorn, entspannen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_17_childs_pose"
        ),
        StretchExercise(
            id: "standing-calf",
            name: "Wadenstretch im Stand",
            description: "Ferse am Boden, Bein gestreckt, Gewicht nach vorn.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_18_standing_calf"
        ),
        StretchExercise(
            id: "seated-forward-fold",
            name: "Sitzende Vorbeuge",
            description: "Sitzend Beine lang, Rücken lang, nach vorn beugen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_20_seated_forward_fold"
        ),
        StretchExercise(
            id: "single-leg-forward-bend",
            name: "Einbeinige Vorbeuge",
            description: "Ein Bein gestreckt, anderes angewinkelt, Oberkörper nach vorn.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_21_single_leg_forward_bend"
        ),
        StretchExercise(
            id: "deep-squat",
            name: "Tiefe Hocke",
            description: "Füße schulterbreit, tief hocken, Brust aufrecht.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_22_deep_squat"
        ),
        StretchExercise(
            id: "seated-half-king-pigeon",
            name: "Sitzende Halbe Taube",
            description: "Ein Bein vorne angewinkelt, anderes nach hinten, Oberkörper aufrecht.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_23_seated_half_king_pigeon"
        ),
        StretchExercise(
            id: "standing-calf-wall",
            name: "Wadenstretch an der Wand",
            description: "Hände an die Wand, hinteres Bein gestreckt, Ferse tief.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_24_standing_calf_wall"
        ),
        StretchExercise(
            id: "lateral-flexion-wall",
            name: "Seitbeuge an der Wand",
            description: "Seitlich zur Wand, Arm über den Kopf, Flanke öffnen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_25_lateral_flexion_wall"
        ),
        StretchExercise(
            id: "supine-twist",
            name: "Liegender Twist",
            description: "Rückenlage, Knie zur Seite, Schultern am Boden.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_26_supine_twist"
        ),
        StretchExercise(
            id: "triangle-pose",
            name: "Dreieck",
            description: "Breit stehen, vorderes Bein gestreckt, Oberkörper seitlich.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_28_triangle_pose"
        ),
        StretchExercise(
            id: "chest-wall",
            name: "Bruststretch an der Wand",
            description: "Unterarm an die Wand, Brust aufdrehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_29_chest_wall"
        ),
        StretchExercise(
            id: "seated-half-pigeon-variation",
            name: "Sitzende Halbe Taube (Variante)",
            description: "Beine verschränkt im Sitz, Rücken lang, leicht nach vorn.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_31_seated_half_pigeon_variation"
        ),
        StretchExercise(
            id: "supine-shoulder-external-rotation",
            name: "Schulter-Außenrotation",
            description: "Rückenlage, Arm 90°, Handrücken zum Boden sinken.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_32_supine_shoulder_external_rotation"
        ),
        StretchExercise(
            id: "down-dog-wall",
            name: "Down-Dog an der Wand",
            description: "Hände an die Wand, Hüfte nach hinten, Rücken lang.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_33_down_dog_wall"
        ),
    ]

    static func exercises(for catalog: StretchCatalogKind) -> [StretchExercise] {
        switch catalog {
        case .legacy:
            return legacyExercises
        case .lifehack:
            return lifehackExercises
        }
    }

    static func pickExercises(
        count: Int,
        preferences: [String: Int],
        catalog: StretchCatalogKind,
        cycleState: StretchCycleState
    ) -> (exercises: [StretchExercise], cycleState: StretchCycleState) {
        guard count > 0 else {
            return ([], cycleState)
        }

        let catalogExercises = exercises(for: catalog)
        guard !catalogExercises.isEmpty else {
            return ([], cycleState)
        }

        var state = cycleState
        if state.catalogId != catalog.rawValue {
            state = StretchCycleState(catalogId: catalog.rawValue, groups: [:])
        }

        let exerciseById = Dictionary(uniqueKeysWithValues: catalogExercises.map { ($0.id, $0) })
        let groupedExercises = groupExercises(catalogExercises, preferences: preferences)
        state.groups = normalizeGroupStates(groups: groupedExercises, existing: state.groups)

        let target = min(count, catalogExercises.count)
        var selected: [StretchExercise] = []
        let weights = groupWeights(for: groupedExercises)

        for _ in 0..<target {
            guard let level = pickLevel(from: weights) else { break }
            let key = levelKey(level)

            guard var groupState = state.groups[key],
                  let group = groupedExercises[level],
                  !group.isEmpty else {
                continue
            }

            let groupIds = group.map { $0.id }
            if !isValidOrder(groupState.order, ids: groupIds) {
                groupState.order = groupIds.shuffled()
                groupState.index = -1
            }

            var nextIndex = groupState.index + 1
            if nextIndex >= groupState.order.count {
                groupState.order = groupIds.shuffled()
                groupState.index = -1
                nextIndex = 0
            }

            if let exercise = exerciseById[groupState.order[nextIndex]] {
                selected.append(exercise)
            }

            groupState.index = nextIndex
            state.groups[key] = groupState
        }

        return (selected, state)
    }

    private static func groupExercises(
        _ exercises: [StretchExercise],
        preferences: [String: Int]
    ) -> [Int: [StretchExercise]] {
        var groups: [Int: [StretchExercise]] = [:]

        for exercise in exercises {
            let rawLevel = preferences[exercise.id] ?? 0
            let level = max(Habit.stretchPreferenceMin, min(Habit.stretchPreferenceMax, rawLevel))
            groups[level, default: []].append(exercise)
        }

        return groups
    }

    private static func normalizeGroupStates(
        groups: [Int: [StretchExercise]],
        existing: [String: StretchCycleGroupState]
    ) -> [String: StretchCycleGroupState] {
        var result: [String: StretchCycleGroupState] = [:]

        for (level, exercises) in groups {
            let key = levelKey(level)
            let ids = exercises.map { $0.id }
            var state = existing[key] ?? StretchCycleGroupState(order: [], index: -1)

            if !isValidOrder(state.order, ids: ids) {
                state.order = ids.shuffled()
                state.index = -1
            }

            if state.index >= state.order.count || state.index < -1 {
                state.index = -1
            }

            result[key] = state
        }

        return result
    }

    private static func groupWeights(for groups: [Int: [StretchExercise]]) -> [(level: Int, weight: Double)] {
        groups.compactMap { level, exercises in
            guard !exercises.isEmpty else { return nil }
            let multiplier = frequencyMultiplier(for: level)
            let weight = Double(exercises.count) * multiplier
            return (level: level, weight: weight)
        }
    }

    private static func frequencyMultiplier(for level: Int) -> Double {
        let clamped = max(Habit.stretchPreferenceMin, min(Habit.stretchPreferenceMax, level))
        return pow(1.25, Double(clamped))
    }

    private static func pickLevel(from weights: [(level: Int, weight: Double)]) -> Int? {
        let total = weights.reduce(0.0) { $0 + $1.weight }
        guard total > 0 else { return nil }
        let roll = Double.random(in: 0..<total)
        var cumulative = 0.0
        for entry in weights {
            cumulative += entry.weight
            if roll < cumulative {
                return entry.level
            }
        }
        return weights.last?.level
    }

    private static func isValidOrder(_ order: [String], ids: [String]) -> Bool {
        guard order.count == ids.count else { return false }
        return Set(order) == Set(ids)
    }

    private static func levelKey(_ level: Int) -> String {
        String(level)
    }

    static func nextExercise(after index: Int, catalog: StretchCatalogKind) -> (StretchExercise, Int) {
        let list = exercises(for: catalog)
        guard !list.isEmpty else {
            return (StretchExercise(id: "none", name: "Dehnung", description: "", symbolName: "figure.mind.and.body"), 0)
        }

        let nextIndex = (index + 1) % list.count
        return (list[nextIndex], nextIndex)
    }
}
