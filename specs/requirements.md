I want to create a really simple AI-powered voice typing application.

The main functionality is that the user only needs to provide an AI service provider API key, for example a Gemini API key.
After that, the user can run the application and detect voice activities.
Once the user finishes voice input, the application calls the AI service provider and transcribes the voice.
There is customized vocabulary to make the transcription accurate and meaningful.
There are custom prompts that can be created, managed, and selected by the user, which will be used when calling the AI service provider API to provide customized output of the transcription.
That's all of the core features.

We will be using Flutter for creating a desktop app, as well as iOS and Android apps. But the interface will remain really simple, clean and modern with beautiful design.

The first page would be a dashboard to show statistics like how many times it has been used, the token usage from the API, the frequency, and recent transcriptions (with a search function and allowing the user to copy them).

The second page could be a settings page that allows users to define custom vocabulary and custom prompts that the user can use.
There will be a default vocabulary and prompt provided, think about the common use cases.
The user is able to select a different one or change to another one if they want.
There will also be an API key input field for the API service provider.
There will also be a global hotkey setting there.
When the user presses the global hotkey, it will activate the application and start recording the voice.
When the user presses the hotkey again, it will stop the recording and start transcribing what the user input is, using the custom vocabulary and prompts to call the API service provider.
Once that is finished, it will show a notification to tell the user and also auto-copy the output to the clipboard.
