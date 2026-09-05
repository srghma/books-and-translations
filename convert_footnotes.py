#!/usr/bin/env python3
r"""
convert_footnotes.py

Transforms detached <sup>\*</sup> footnotes in Markdown chapters into
inline <footnote>...</footnote> tags at their call sites, and heals the
interrupted paragraph text that had been split across page boundaries.
"""

import os
import sys

BASE_DIR = "The Beginning of Infinity"

CHANGES = {
    "1. The Reach of Explanations.md": [
        # Call site
        (
            "_theory-laden_,\\* and hence fallible, as all our theories are.",
            "_theory-laden_,<footnote>The term was coined by the philosopher Norwood Russell Hanson.</footnote> and hence fallible, as all our theories are.",
        ),
        # Remove footnote line
        (
            "\n\n<sup>\\*</sup>The term was coined by the philosopher Norwood Russell Hanson.\n\n",
            "\n\n",
        ),
    ],
    "4. Creation.md": [
        # Call site 1
        (
            "(anything that contributes causally to its own copying).\\* For instance",
            "(anything that contributes causally to its own copying).<footnote>This terminology differs slightly from that of Dawkins. Anything that is copied, for whatever reason, he calls a replicator. What I call a replicator he calls an 'active replicator'.</footnote> For instance",
        ),
        # Delete footnote 1 and rejoin split paragraph
        (
            "Genes _often_ do this by imparting useful functionality to their organism, and in those cases\n\n<sup>\\*</sup>This terminology differs slightly from that of Dawkins. Anything that is copied, for whatever reason, he calls a replicator. What I call a replicator he calls an 'active replicator'.\n\ntheir knowledge incidentally includes knowledge about that functionality.",
            "Genes _often_ do this by imparting useful functionality to their organism, and in those cases their knowledge incidentally includes knowledge about that functionality.",
        ),
        # Call site 2
        (
            "parallel universes\\* – with different laws.",
            "parallel universes<footnote>These are not the 'parallel universes' of the _quantum_ multiverse, which I shall describe in Chapter 11. Those universes all obey the same laws of physics and are in constant slight interaction with each other. They are also much less speculative.</footnote> – with different laws.",
        ),
        # Delete footnote 2
        (
            "\n\n<sup>\\*</sup>These are not the 'parallel universes' of the _quantum_ multiverse, which I shall describe in Chapter 11. Those universes all obey the same laws of physics and are in constant slight interaction with each other. They are also much less speculative.\n\n",
            "\n\n",
        ),
    ],
    "7. Artificial Creativity.md": [
        # Call site
        (
            "look like 'machines that think'.\\* Others maintain",
            "look like 'machines that think'.<footnote>Hence what I am calling 'AI' is sometimes called 'AGI': Artificial _General_ Intelligence.</footnote> Others maintain",
        ),
        # Delete footnote and rejoin split paragraph
        (
            "the laptop computer on which I am writing this book has over a thousand times as much memory as Turing\n\n<sup>\\*</sup> Hence what I am calling 'AI' is sometimes called 'AGI': Artificial _General_ Intelligence.\n\nspecified (counting hard-drive space), and about a million times the speed",
            "the laptop computer on which I am writing this book has over a thousand times as much memory as Turing specified (counting hard-drive space), and about a million times the speed",
        ),
    ],
    "8. A Window on Infinity.md": [
        # Call site
        (
            "can see in this footnote.\\* The upshot is: everyone is accommodated.",
            "can see in this footnote.<footnote>First, they announce to the existing guests, 'For each natural number _N_, will the guest in room number _N_ please move immediately to room number _N_ (_N_ + 1)/2.' Then they announce, 'For all natural numbers _N_ and _M_, will the *N*th passenger from the *M*th train please go to room number [(_N_ + _M_) <sup>2</sup> + _N_ – _M_]/2.'</footnote> The upshot is: everyone is accommodated.",
        ),
        # Delete footnote and rejoin split paragraph
        (
            "It is impossible to deal out\n\n<sup>\\*</sup>First, they announce to the existing guests, 'For each natural number _N_, will the guest in room number _N_ please move immediately to room number _N_ (_N_ + 1)/2.' Then they announce, 'For all natural numbers _N_ and _M_, will the *N*th passenger from the *M*th train please go to room number [(_N_ + _M_) <sup>2</sup> + _N_ – _M_]/2.'\n\none of these cards to each room of Infinity Hotel.",
            "It is impossible to deal out one of these cards to each room of Infinity Hotel.",
        ),
    ],
    "10. A Dream of Socrates.md": [
        # Call site 1
        (
            "who the wisest man in the world is,\\* so that they might go and learn from him.",
            "who the wisest man in the world is,<footnote>In the story as told by Plato in his _Apology_, Chaerophon asks the Oracle _whether_ there is anyone wiser than Socrates, and is told no. But would he really have wasted this expensive and solemn privilege on a question with only two possible answers, one flattering, the other frustrating, and neither very interesting?</footnote> so that they might go and learn from him.",
        ),
        # Delete footnote 1
        (
            "\n\n<sup>\\*</sup>In the story as told by Plato in his _Apology_, Chaerophon asks the Oracle _whether_ there is anyone wiser than Socrates, and is told no. But would he really have wasted this expensive and solemn privilege on a question with only two possible answers, one flattering, the other frustrating, and neither very interesting?\n\n",
            "\n\n",
        ),
        # Call site 2
        (
            "against overwhelming odds,\\* and now we are defying Sparta.",
            "against overwhelming odds,<footnote>In this dialogue, Socrates sometimes exaggerates the attributes and achievements of his beloved home city-state, Athens. In this case he is ignoring the contributions of other Greek city-states to the defeats of two invasion attempts by the Persian Empire, both of them before he was born.</footnote> and now we are defying Sparta.",
        ),
        # Delete footnote 2
        (
            "\n\n<sup>\\*</sup>In this dialogue, Socrates sometimes exaggerates the attributes and achievements of his beloved home city-state, Athens. In this case he is ignoring the contributions of other Greek city-states to the defeats of two invasion attempts by the Persian Empire, both of them before he was born.\n\n",
            "\n\n",
        ),
        # Call site 3
        (
            "Through seeking we may learn and know things better.\\*",
            "Through seeking we may learn and know things better.<footnote>Popper's translation in _The World of Parmenides_ (1998).</footnote>",
        ),
        # Delete footnote 3 and rejoin Socrates speech
        (
            "Hence they do not believe that 'in the course of time they may\n\n<sup>\\*</sup>Popper's translation in _The World of Parmenides_ (1998).\n\nlearn and know things better.'",
            "Hence they do not believe that 'in the course of time they may learn and know things better.'",
        ),
        # Call site 4
        (
            "nor just a matter of degree.\\* Let me restate it:",
            "nor just a matter of degree.<footnote>I shall say more about the difference between those two kinds of society – which I call _static_ and _dynamic_ societies – in Chapter 15.</footnote> Let me restate it:",
        ),
        # Delete footnote 4 and rejoin Hermes speech
        (
            "hermes: Yet there is even more of a difference than you think. Bear\n\n<sup>\\*</sup>I shall say more about the difference between those two kinds of society – which I call _static_ and _dynamic_ societies – in Chapter 15.\n\nin mind that the Spartans and Athenians alike are but fallible men",
            "hermes: Yet there is even more of a difference than you think. Bear in mind that the Spartans and Athenians alike are but fallible men",
        ),
        # Call site 5
        (
            "through their new explanations.\\*",
            "through their new explanations.<footnote>Which some would mistakenly think were 'derived from experience'.</footnote>",
        ),
        # Delete footnote 5
        (
            "\n\n<sup>\\*</sup>Which some would mistakenly think were 'derived from experience'.\n\n",
            "\n\n",
        ),
        # Call site 6
        (
            "at the location of the object.\\*",
            "at the location of the object.<footnote>The ancient Greeks were not very clear about where sensory experiences are located. Even in the case of vision, many in Socrates' time believed that the eye _emits_ something like light, and that the sensation of seeing an object consists of some sort of interaction between the object and that light.</footnote>",
        ),
        # Delete footnote 6
        (
            "\n\n<sup>\\*</sup>The ancient Greeks were not very clear about where sensory experiences are located. Even in the case of vision, many in Socrates' time believed that the eye _emits_ something like light, and that the sensation of seeing an object consists of some sort of interaction between the object and that light.\n\n",
            "\n\n",
        ),
        # Call site 7
        (
            "sort of waking dream of reality.\\* hermes: Yes.",
            "sort of waking dream of reality.<footnote>Our experience of the world is indeed a form of virtual-reality rendering which happens wholly inside the brain.</footnote> hermes: Yes.",
        ),
        # Delete footnote 7 and rejoin Socrates speech
        (
            "And that what I _experience_ as reality is never more than a\n\n<sup>\\*</sup>Our experience of the world is indeed a form of virtual-reality rendering which happens wholly inside the brain.\n\nwaking dream, composed of conjectures originating from within myself?",
            "And that what I _experience_ as reality is never more than a waking dream, composed of conjectures originating from within myself?",
        ),
        # Call site 8
        (
            "what stands on our Acropolis?\\* And, however much",
            "what stands on our Acropolis?<footnote>Namely the Parthenon.</footnote> And, however much",
        ),
        # Delete footnote 8 from Plato line
        (
            "plato: [_Scribbles,_ '_Sparta's Achilles' heel is that they don't improve.'_] \\*Namely the Parthenon.",
            "plato: [_Scribbles,_ '_Sparta's Achilles' heel is that they don't improve.'_]",
        ),
    ],
    "11. The Multiverse.md": [
        # Call site 1
        (
            "fan: Aw, for glayvin\\* out loud!",
            "fan: Aw, for glayvin<footnote>'Glayvin' is a term of indeterminate meaning, coined by _The Simpsons_.</footnote> out loud!",
        ),
        # Delete footnote 1 and rejoin paragraph
        (
            "In that spirit, then, consider the fictional doppelgängers in the\n\n<sup>\\*&#</sup>x27;Glayvin' is a term of indeterminate meaning, coined by _The Simpsons_.\n\nphantom zone. What enables them to _see_ the ordinary world?",
            "In that spirit, then, consider the fictional doppelgängers in the phantom zone. What enables them to _see_ the ordinary world?",
        ),
        # Call site 2
        (
            "make them non-fungible.\\* It is not that they coincide",
            "make them non-fungible.<footnote>Identical entities that were at different locations _in an otherwise empty space_ would not be fungible, but some philosophers have argued that they would be 'indiscernible' in Leibniz's sense. If so, then this is yet another respect in which fungibility is worse than Leibniz imagined.</footnote> It is not that they coincide",
        ),
        # Delete footnote 2 and rejoin paragraph
        (
            "is that the factors affecting the phenomenon,\n\n<sup>\\*</sup>Identical entities that were at different locations _in an otherwise empty space_ would not be fungible, but some philosophers have argued that they would be 'indiscernible' in Leibniz's sense. If so, then this is yet another respect in which fungibility is worse than Leibniz imagined.\n\nthough deterministic, are either unknown or too complex to take account of.",
            "is that the factors affecting the phenomenon, though deterministic, are either unknown or too complex to take account of.",
        ),
        # Call site 3
        (
            "It is known as _entanglement_ information.\\*",
            "It is known as _entanglement_ information.<footnote>That this information is carried entirely locally in objects is currently somewhat controversial. For a detailed technical discussion see the paper 'Information Flow in Entangled Quantum Systems' by myself and Patrick Hayden (_Proceedings of the Royal Society_ A456 (2000)).</footnote>",
        ),
        # Delete footnote 3 and rejoin paragraph
        (
            "The multiverse explanation of the same events would be a bad\n\n<sup>\\*</sup>That this information is carried entirely locally in objects is currently somewhat controversial. For a detailed technical discussion see the paper 'Information Flow in Entangled Quantum Systems' by myself and Patrick Hayden (_Proceedings of the Royal Society_ A456 (2000)).\n\nexplanation, and so the world would be inexplicable to the inhabitants if it were true.",
            "The multiverse explanation of the same events would be a bad explanation, and so the world would be inexplicable to the inhabitants if it were true.",
        ),
    ],
    "13. Choices.md": [
        # Call site 1
        (
            "was still considered an injustice by many.\\* The same controversy exists",
            "was still considered an injustice by many.<footnote>This rule is often misinterpreted as illustrating how slaves were regarded as less than fully human. But that has nothing to do with the issue. Black people were indeed widely regarded as being inferior to white ones, but this particular measure was designed to _reduce_ the power of slave-owning states compared to what it would have been if slaves had been counted like everyone else.</footnote> The same controversy exists",
        ),
        # Delete footnote 1 and rejoin paragraph
        (
            "apportion ment purposes. So\n\n<sup>\\*</sup>This rule is often misinterpreted as illustrating how slaves were regarded as less than fully human. But that has nothing to do with the issue. Black people were indeed widely regarded as being inferior to white ones, but this particular measure was designed to _reduce_ the power of slave-owning states compared to what it would have been if slaves had been counted like everyone else.\n\nstates with large numbers of illegal immi grants receive extra seats",
            "apportion ment purposes. So states with large numbers of illegal immi grants receive extra seats",
        ),
        # Call site 2
        (
            "then he was simply mistaken.\\* The National Academy of Sciences panel",
            "then he was simply mistaken.<footnote>It should of course be physicists.</footnote> The National Academy of Sciences panel",
        ),
        # Delete footnote 2 and rejoin paragraph
        (
            "a consensus had emerged among most major\n\n<sup>\\*</sup>It should of course be physicists.\n\npolitical movements that the future welfare of humankind",
            "a consensus had emerged among most major political movements that the future welfare of humankind",
        ),
        # Call site 3
        (
            "Free Democratic Party (FDP) was the third largest.\\* Though it never received",
            "Free Democratic Party (FDP) was the third largest.<footnote>I am counting the Christian Democrat CDU and the regionally based CSU as being one party for present purposes.</footnote> Though it never received",
        ),
        # Delete footnote 3 and rejoin paragraph
        (
            "gave it power that was\n\n<sup>\\*</sup>I am counting the Christian Democrat CDU and the regionally based CSU as being one party for present purposes.\n\ninsensitive to changes in the voters' opinions.",
            "gave it power that was insensitive to changes in the voters' opinions.",
        ),
    ],
    "18. The Beginning.md": [
        # Call site
        (
            "dispense with all those parallel universes,\\* they could dispense with the variant",
            "dispense with all those parallel universes,<footnote>Let me remind the reader that these highly speculative parallel universes have nothing to do with the universes or histories in the quantum multiverse, for whose existence there is overwhelming evidence. Strictly speaking, the standard anthropic ex planations postulate infinitely many quantum _multiverses_.</footnote> they could dispense with the variant",
        ),
        # Delete footnote and rejoin paragraph
        (
            "Hence we also know that it is non-zero for almost any values. It is\n\n<sup>\\*</sup>Let me remind the reader that these highly speculative parallel universes have nothing to do with the universes or histories in the quantum multiverse, for whose existence there is overwhelming evidence. Strictly speaking, the standard anthropic ex planations postulate infinitely many quantum _multiverses_.\n\npresumably unimaginably tiny for almost all sets of values",
            "Hence we also know that it is non-zero for almost any values. It is presumably unimaginably tiny for almost all sets of values",
        ),
    ],
}

def main():
    dry_run = "--dry-run" in sys.argv
    all_ok = True

    for filename, replacements in CHANGES.items():
        filepath = os.path.join(BASE_DIR, filename)
        if not os.path.exists(filepath):
            print(f"ERROR: File not found: {filepath}")
            all_ok = False
            continue

        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        file_ok = True
        modified = content
        for idx, (target, replacement) in enumerate(replacements):
            count = modified.count(target)
            if count != 1:
                print(f"ERROR in {filename} replacement #{idx+1}: target found {count} times (expected 1).")
                print(f"Target snippet: {target[:60]!r}...")
                file_ok = False
                all_ok = False
            else:
                modified = modified.replace(target, replacement, 1)

        if file_ok:
            print(f"OK: {filename} ({len(replacements)} replacements)")
            if not dry_run:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(modified)

    if not all_ok:
        sys.exit(1)
    print("All replacements completed successfully!")

if __name__ == "__main__":
    main()
