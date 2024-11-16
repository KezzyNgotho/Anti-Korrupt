<script lang="ts">
  import Router from "svelte-spa-router";
  import { onMount } from "svelte";
  import { store } from "./store";

  // Your route components
  import NotFound from "./pages/NotFound.svelte";
  import SelectModel from "./components/SelectModel.svelte";

  const routes = {
    "/": SelectModel,
    "*": NotFound,
  };

  onMount(async () => {
    // Check login state or other setup
    await store.checkExistingLoginAndConnect();
    if ($store.isAuthed) {
      // Handle authentication status
    }
  });
</script>

<div class="App">
  <Router {routes} />
</div>
