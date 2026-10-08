"""Azulejo Brutalism themes for Mistral Vibe's Textual TUI.

Installed as a module plus a .pth hook in the mistral-vibe Python environment:
the .pth imports this module at interpreter startup, which registers the themes
into Textual's BUILTIN_THEMES dict. Vibe validates the `theme` config value
against that dict and lists the /theme picker from it, so the themes behave
exactly like Textual's built-ins. The Python (Textual) TUI only; the
experimental Rust TUI does not see them.
"""

from __future__ import annotations


def _register() -> None:
    try:
        from textual.theme import BUILTIN_THEMES, Theme
    except ImportError:
        return

    light = Theme(
        name="azulejo-brutalism-light",
        primary="#1E2A9E",  # cobalt
        secondary="#1D6E7E",  # teal
        warning="#8F6200",  # ochre, darkened for contrast on glaze
        error="#B03A2E",
        success="#2F6B3A",
        accent="#D49A1A",  # ochre, the one highlight
        foreground="#0C1030",  # ink
        background="#F3F0E8",  # glaze
        surface="#E8E4D9",
        panel="#DEDAD0",
        dark=False,
        variables={
            "block-cursor-background": "#D49A1A",
            "block-cursor-foreground": "#F3F0E8",
            "footer-key-foreground": "#1E2A9E",
            "input-selection-background": "#9FB2E4 45%",  # wash
            "button-color-foreground": "#F3F0E8",
        },
    )
    dark = Theme(
        name="azulejo-brutalism-dark",
        primary="#9FB2E4",  # wash; cobalt vanishes on ink
        secondary="#6FC3CF",  # teal
        warning="#D49A1A",  # ochre
        error="#E0705A",
        success="#7CBF7A",
        accent="#D49A1A",  # ochre, the one highlight
        foreground="#F3F0E8",  # glaze
        background="#0C1030",  # ink
        surface="#10154A",
        panel="#1A2150",
        dark=True,
        variables={
            "block-cursor-background": "#D49A1A",
            "block-cursor-foreground": "#0C1030",
            "footer-key-foreground": "#9FB2E4",
            "input-selection-background": "#1E2A9E 60%",  # cobalt grout
            "button-color-foreground": "#0C1030",
        },
    )
    # OLED: Dark with true black behind everything; surfaces sink one step toward black.
    oled = Theme(
        name="azulejo-brutalism-oled",
        primary="#9FB2E4",
        secondary="#6FC3CF",
        warning="#D49A1A",
        error="#E0705A",
        success="#7CBF7A",
        accent="#D49A1A",
        foreground="#F3F0E8",
        background="#000000",
        surface="#07091F",
        panel="#0C1030",
        dark=True,
        variables={
            "block-cursor-background": "#D49A1A",
            "block-cursor-foreground": "#000000",
            "footer-key-foreground": "#9FB2E4",
            "input-selection-background": "#1E2A9E 60%",
            "button-color-foreground": "#000000",
        },
    )
    for theme in (light, dark, oled):
        BUILTIN_THEMES.setdefault(theme.name, theme)


_register()
