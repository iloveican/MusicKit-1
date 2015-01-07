//  Copyright (c) 2015 Ben Guo. All rights reserved.

import Foundation

public struct PitchSet : CollectionType {

    var pitches : [Pitch] = []
    public let startIndex : Int = 0
    public let endIndex : Int

    public init(scale: Scale, firstPitch: Pitch, count: Int) {
        self.endIndex = count - 1
        pitches.append(firstPitch)
        var previousPitch = firstPitch
        var scaleLength = scale.intervals.count
        var midiNum = firstPitch.midiNumber
        for var i=1; i<count; i++ {
            let prevDegree = (i-1)%scaleLength
            midiNum = midiNum + scale.intervals[prevDegree]
            var pitch = Pitch(midiNumber: midiNum)

            // if the scale is diatonic and the current and previous pitch
            /// have names, set a preferred pitch class name
            if scaleLength == 7 {
                if let pitchClass = pitch.pitchClass {
                    if let previousPitchName = previousPitch.noteNameTuple {
                        let preferredLetterName = previousPitchName.0.next()
                        let preferredPitchName = pitchClass.names.filter {
                            n in n.0 == preferredLetterName
                            }.first
                        pitch.preferredName = preferredPitchName
                    }
                }
            }

            pitches.append(pitch)
            previousPitch = pitch
        }
    }

    public init(chord: Chord, firstPitch: Pitch, count: Int) {
        self.endIndex = count - 1

        pitches.append(firstPitch)
        var previousPitch = firstPitch
        var chordLength = chord.intervals.count
        var midiNum = firstPitch.midiNumber
        for var i=1; i<count; i++ {
            let firstInterval = chord.intervals[(i-1) % chordLength]
            let secondInterval = chord.intervals[i % chordLength]
            var delta : Float = 0.0

            if secondInterval >= firstInterval {
                delta = secondInterval - firstInterval
            }
            else {
                delta = secondInterval + 12 - firstInterval
            }
            midiNum += delta
            var pitch = Pitch(midiNumber: midiNum)

            // set a preferred pitch class name
            if i < chordLength {
                if let pitchClass = pitch.pitchClass {
                    if let previousPitchName = previousPitch.noteNameTuple {
                        var preferredLetterName : LetterName?
                        // maj/min second
                        if delta == 1 || delta == 2 {
                            preferredLetterName = previousPitchName.0.next()
                        }
                        // maj/min third
                        else if delta == 3 || delta == 4 {
                            preferredLetterName = previousPitchName.0.next().next()
                        }
                        let preferredPitchName = pitchClass.names.filter {
                            n in n.0 == preferredLetterName
                            }.first
                        pitch.preferredName = preferredPitchName
                    }
                }
            }
            else {
                let pitchOctaveBelow = pitches[i - chordLength]
                pitch.preferredName = pitchOctaveBelow.preferredName
            }

            pitches.append(pitch)
            previousPitch = pitch
        }

    }

    public func generate() -> GeneratorOf<Pitch> {
        var index = startIndex
        return GeneratorOf<Pitch> {
            if index <= self.endIndex {
                let pitch = self.pitches[index]
                index++
                return pitch
            }
            else {
                return nil
            }
        }
    }

    public subscript(i: Int) -> Pitch {
        return pitches[i]
    }
}


