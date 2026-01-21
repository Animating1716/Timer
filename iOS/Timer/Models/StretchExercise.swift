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
            id: "camel-pose",
            name: "Kamel",
            description: "Knie dich hin, Hände an die Fersen, Brust öffnen und Hüfte nach vorn schieben.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_camel_pose"
        ),
        StretchExercise(
            id: "wide-forward-fold",
            name: "Breite Vorbeuge",
            description: "Breit stehen, lang werden und mit geradem Rücken nach vorn beugen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_wide_forward_fold"
        ),
        StretchExercise(
            id: "right-angle-pose",
            name: "Rechter Winkel",
            description: "In den Ausfallschritt, vorderes Knie 90°, Arme gestreckt über dem Kopf.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_right_angle"
        ),
        StretchExercise(
            id: "triangle-pose",
            name: "Dreieck",
            description: "Füße weit, vorderes Bein gestreckt, Oberkörper zur Seite neigen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_triangle"
        ),
        StretchExercise(
            id: "downward-dog",
            name: "Herabschauender Hund",
            description: "Hände und Füße am Boden, Hüfte hoch, Fersen Richtung Boden drücken.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_downward_dog"
        ),
        StretchExercise(
            id: "plow-pose",
            name: "Pflug",
            description: "Aus der Rückenlage Beine über den Kopf führen, Rücken lang lassen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_plow"
        ),
        StretchExercise(
            id: "standing-forward-fold",
            name: "Stehende Vorbeuge",
            description: "Hüftbreit stehen und aus der Hüfte nach vorn beugen, Nacken locker.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_standing_forward_fold"
        ),
        StretchExercise(
            id: "shoulder-opening",
            name: "Schulteröffner",
            description: "Knieend Hände hinter dem Rücken verschränken und Arme nach oben ziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_shoulder_opening"
        ),
        StretchExercise(
            id: "crescent-lunge",
            name: "Crescent Lunge",
            description: "Tiefer Ausfallschritt, Becken nach vorn, Arme nach oben strecken.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_crescent_lunge"
        ),
        StretchExercise(
            id: "pigeon-pose",
            name: "Taube",
            description: "Vorderes Bein angewinkelt ablegen, hinteres Bein lang, Oberkörper sinken lassen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_pigeon"
        ),
        StretchExercise(
            id: "bridge-pose",
            name: "Brücke",
            description: "Rückenlage, Füße aufstellen, Becken anheben und Brust öffnen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_bridge"
        ),
        StretchExercise(
            id: "side-lunge",
            name: "Seitlicher Ausfallschritt",
            description: "In die Seite sinken, ein Bein beugen, anderes strecken, Hüfte tief halten.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_side_lunge"
        ),
        StretchExercise(
            id: "locust-pose",
            name: "Heuschrecke",
            description: "Bauchlage, Beine und Brust leicht anheben, Arme nach hinten strecken.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_locust"
        ),
        StretchExercise(
            id: "supine-twist",
            name: "Liegender Twist",
            description: "Rückenlage, Knie zur Seite fallen lassen, Schultern am Boden halten.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_supine_twist"
        ),
        StretchExercise(
            id: "seated-wide-angle",
            name: "Sitzende Grätsche",
            description: "Sitzend Beine weit, Rücken lang, nach vorn beugen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_seated_wide_angle"
        ),
        StretchExercise(
            id: "happy-baby",
            name: "Glückliches Baby",
            description: "Rückenlage, Knie zur Brust, Fußsohlen greifen und sanft ziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_happy_baby"
        ),
        StretchExercise(
            id: "half-split",
            name: "Halber Spagat",
            description: "Im Ausfallschritt vorderes Bein strecken, Hüfte zurückziehen, Oberkörper nach vorn.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_half_split"
        ),
        StretchExercise(
            id: "big-toe-stretch",
            name: "Großzehen-Stretch",
            description: "Sitzend ein Bein strecken, Fuß greifen und Bein Richtung Gesicht ziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_big_toe"
        ),
        StretchExercise(
            id: "head-to-knee",
            name: "Kopf-zum-Knie",
            description: "Sitzend ein Bein gestreckt, anderes angewinkelt, Oberkörper zum gestreckten Bein.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_head_to_knee"
        ),
        StretchExercise(
            id: "cow-face",
            name: "Kuhgesicht",
            description: "Sitzend Beine übereinander, Fußsohlen neben dem Gesäß, Rücken aufrecht.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_cow_face"
        ),
        StretchExercise(
            id: "cat-cow",
            name: "Katze/Kuh",
            description: "Im Vierfüßler abwechselnd Wirbelsäule runden und ins Hohlkreuz kommen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_cat_cow"
        ),
        StretchExercise(
            id: "forearm-stretch",
            name: "Unterarm-Stretch",
            description: "Arm strecken, Handfläche nach oben, Finger sanft nach unten ziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_forearm"
        ),
        StretchExercise(
            id: "neck-stretch",
            name: "Nacken-Stretch",
            description: "Aufrecht sitzen, Kopf zur Seite neigen, Hand sanft nachziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_neck"
        ),
        StretchExercise(
            id: "spinal-twist",
            name: "Wirbelsäulen-Drehung",
            description: "Aufrecht sitzen, ein Bein überkreuzen, Oberkörper zur Seite drehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_spinal_twist"
        ),
        StretchExercise(
            id: "cow-face-arms",
            name: "Kuhgesicht Arme",
            description: "Einen Arm über den Kopf beugen, anderen von unten fassen, Hände annähern.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_cow_face_arms"
        ),
        StretchExercise(
            id: "straight-leg-forward-fold",
            name: "Vorbeuge gestreckt",
            description: "Sitzend Beine gestreckt, Rücken lang, nach vorn gleiten.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_straight_leg_forward_fold"
        ),
        StretchExercise(
            id: "figure-four",
            name: "Figure-4-Stretch",
            description: "Rückenlage, Fuß auf anderes Knie legen, Oberschenkel heranziehen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_figure_four"
        ),
        StretchExercise(
            id: "lying-quad",
            name: "Liegender Quadrizeps",
            description: "Seit-/Rückenlage, Ferse Richtung Gesäß ziehen, Knie zusammen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_lying_quad"
        ),
        StretchExercise(
            id: "hip-flexor-lifehack",
            name: "Hüftbeuger",
            description: "Tiefer Ausfallschritt, Becken nach vorn schieben, Rücken aufrecht.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_hip_flexor"
        ),
        StretchExercise(
            id: "butterfly",
            name: "Schmetterling",
            description: "Sitzend Fußsohlen zusammen, Knie nach außen sinken lassen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_butterfly"
        ),
        StretchExercise(
            id: "hip-stretch",
            name: "Hüft-Stretch",
            description: "Sitzend ein Bein vor dem Körper, anderes seitlich, Oberkörper nach vorn.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_hip_stretch"
        ),
        StretchExercise(
            id: "star-pose",
            name: "Stern",
            description: "Breit stehen, Arme weit, Oberkörper seitlich neigen, Länge in der Flanke.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_star"
        ),
        StretchExercise(
            id: "double-pigeon",
            name: "Doppel-Taube",
            description: "Sitzend beide Schienbeine übereinander, nach vorn beugen.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_double_pigeon"
        ),
        StretchExercise(
            id: "childs-pose",
            name: "Kindhaltung",
            description: "Aus dem Kniestand Gesäß auf die Fersen, Arme lang nach vorn.",
            symbolName: "figure.mind.and.body",
            imageName: "lifehack_childs_pose"
        )
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
        catalog: StretchCatalogKind
    ) -> [StretchExercise] {
        guard count > 0 else { return [] }
        var available = exercises(for: catalog)
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

    static func nextExercise(after index: Int, catalog: StretchCatalogKind) -> (StretchExercise, Int) {
        let list = exercises(for: catalog)
        guard !list.isEmpty else {
            return (StretchExercise(id: "none", name: "Dehnung", description: "", symbolName: "figure.mind.and.body"), 0)
        }

        let nextIndex = (index + 1) % list.count
        return (list[nextIndex], nextIndex)
    }
}
