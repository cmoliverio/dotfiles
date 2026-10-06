#!/usr/bin/env python3
"""Create a JetBrainsMono Nerd Font variant with arrow-only ligatures."""

from __future__ import annotations

import argparse
from pathlib import Path

from fontTools.ttLib import TTFont


ARROW_GLYPHS = {
    "hyphen_greater.liga",              # ->
    "less_hyphen.liga",                 # <-
    "hyphen_hyphen_greater.liga",       # -->
    "less_hyphen_hyphen.liga",          # <--
    "less_hyphen_greater.liga",         # <->
}

FAMILY = "JetBrainsMono Arrow NF"
TYPOGRAPHIC_FAMILY = "JetBrainsMono Arrow Nerd Font"
POSTSCRIPT_FAMILY = "JetBrainsMonoArrowNF"


def referenced_lookups(subtable: object) -> set[int]:
    records = list(getattr(subtable, "SubstLookupRecord", []) or [])
    for set_name in (
        "ChainSubRuleSet",
        "ChainSubClassSet",
        "SubRuleSet",
        "SubClassSet",
    ):
        for rule_set in getattr(subtable, set_name, []) or []:
            if rule_set is None:
                continue
            for rule_name in (
                "ChainSubRule",
                "ChainSubClassRule",
                "SubRule",
                "SubClassRule",
            ):
                for rule in getattr(rule_set, rule_name, []) or []:
                    records.extend(getattr(rule, "SubstLookupRecord", []) or [])
    return {record.LookupListIndex for record in records}


def keep_arrow_ligatures(font: TTFont) -> None:
    gsub = font["GSUB"].table
    lookups = gsub.LookupList.Lookup

    producers: dict[str, set[int]] = {glyph: set() for glyph in ARROW_GLYPHS}
    for lookup_index, lookup in enumerate(lookups):
        for subtable in lookup.SubTable:
            for output_glyph in getattr(subtable, "mapping", {}).values():
                if output_glyph in producers:
                    producers[output_glyph].add(lookup_index)

    missing = sorted(glyph for glyph, indices in producers.items() if not indices)
    if missing:
        raise RuntimeError(f"Font is missing expected arrow glyphs: {', '.join(missing)}")

    producer_indices = set().union(*producers.values())
    arrow_lookups: set[int] = set()
    for lookup_index, lookup in enumerate(lookups):
        nested = set()
        for subtable in lookup.SubTable:
            nested.update(referenced_lookups(subtable))
        if nested & producer_indices:
            arrow_lookups.add(lookup_index)

    calt_features = [
        record.Feature
        for record in gsub.FeatureList.FeatureRecord
        if record.FeatureTag == "calt"
    ]
    if not calt_features:
        raise RuntimeError("Font has no contextual-alternates (calt) feature")

    retained = set()
    for feature in calt_features:
        retained.update(set(feature.LookupListIndex) & arrow_lookups)
        feature.LookupListIndex = [
            index for index in feature.LookupListIndex if index in arrow_lookups
        ]
        feature.LookupCount = len(feature.LookupListIndex)

    if len(retained) != len(ARROW_GLYPHS):
        raise RuntimeError(
            f"Expected {len(ARROW_GLYPHS)} arrow lookups, found {len(retained)}"
        )


def rename_family(font: TTFont) -> str:
    name_table = font["name"]
    style = "Regular"
    for record in name_table.names:
        if record.nameID == 2:
            style = record.toUnicode()
            break

    replacements = {
        1: FAMILY,
        3: f"{FAMILY} {style} arrow-only",
        4: f"{FAMILY} {style}",
        6: f"{POSTSCRIPT_FAMILY}-{style.replace(' ', '')}",
        16: TYPOGRAPHIC_FAMILY,
        21: FAMILY,
    }
    for record in name_table.names:
        replacement = replacements.get(record.nameID)
        if replacement is not None:
            record.string = replacement.encode(record.getEncoding())
    return style.replace(" ", "")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output_directory", type=Path)
    args = parser.parse_args()

    font = TTFont(args.source)
    keep_arrow_ligatures(font)
    style = rename_family(font)

    args.output_directory.mkdir(parents=True, exist_ok=True)
    output = args.output_directory / f"JetBrainsMonoArrowNerdFont-{style}.ttf"
    font.save(output)
    print(output)


if __name__ == "__main__":
    main()
