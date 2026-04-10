# Text Bubble BLoC Architecture

## Overview
The Text Bubble BLoC manages the state for text message bubbles, including text content and formatter application.

## Components

### Events
- **InitializeTextEvent**: Initialize bubble with text and formatters
- **UpdateTextEvent**: Update text content
- **ApplyFormattersEvent**: Apply text formatters (mentions, URLs, etc.)

### States
- **TextBubbleInitial**: Initial empty state
- **TextBubbleLoaded**: Main state with text data
  - `text`: The text content to display
  - `formatters`: List of text formatters (CometChatTextFormatter)
  - `isFormatted`: Flag indicating formatters have been applied

### Computed Properties
- `hasText`: Text is not empty
- `hasFormatters`: Formatters list is not empty

## Usage Example

```dart
// Create BLoC
final bloc = TextBubbleBloc();

// Initialize
bloc.add(InitializeTextEvent(
  text: 'Hello @user, check this: https://example.com',
  formatters: [
    CometChatMentionsFormatter(),
    CometChatUrlFormatter(),
  ],
));

// Listen to state
BlocBuilder<TextBubbleBloc, TextBubbleBlocState>(
  builder: (context, state) {
    if (!state.hasText) {
      return SizedBox.shrink();
    }
    
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: FormatterUtils.buildTextSpan(
          state.text,
          state.formatters,
          context,
          alignment,
        ),
      ),
    );
  },
);
```

## State Flow
1. **Initialize** → TextBubbleLoaded with text and formatters
2. **Apply Formatters** → isFormatted = true
3. **Update Text** → New text set, isFormatted = false
4. **Reapply Formatters** → isFormatted = true

## Integration Notes
- Text formatting is done in view layer using FormatterUtils
- Supports CometChatTextFormatter implementations:
  - CometChatMentionsFormatter
  - CometChatUrlFormatter
  - CometChatPhoneFormatter
  - Custom formatters
- BLoC mainly tracks state, actual formatting is view concern
- Lightweight state management for simple text display
- Can be extended for rich text editing features
