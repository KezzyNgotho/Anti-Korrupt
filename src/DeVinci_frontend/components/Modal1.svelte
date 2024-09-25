<!-- src/DeVinci_frontend/components/Modal.svelte -->
<script>
    export let showModal = false;
    export let modalContent = {};
    export let onClose;
  
    const handleClose = () => {
      onClose();
    };
  </script>
  
  {#if showModal}
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow-lg max-w-lg w-full p-6 relative">
        <button 
          on:click={handleClose} 
          class="absolute top-2 right-2 text-gray-500 hover:text-gray-700 text-2xl font-bold"
          aria-label="Close Modal"
        >
          &times;
        </button>
        <h2 class="text-2xl font-bold text-[#023e8a] mb-4">{modalContent.title}</h2>
        <img src={modalContent.image} alt={modalContent.title} class="w-full h-60 object-cover rounded-md mb-4" />
        <p class="text-gray-700 mb-4">{modalContent.description}</p>
        <div class="flex flex-wrap gap-2 mb-4">
          {#each modalContent.tags as tag}
            <span class="text-sm bg-blue-100 text-blue-800 px-2 py-1 rounded-full">{tag}</span>
          {/each}
        </div>
        <div class="flex items-center mb-4">
          <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.286 3.957a1 1 0 00.95.69h4.154c.969 0 1.371 1.24.588 1.81l-3.364 2.448a1 1 0 00-.364 1.118l1.286 3.957c.3.921-.755 1.688-1.54 1.118L10 13.347l-3.364 2.448c-.785.57-1.84-.197-1.54-1.118l1.286-3.957a1 1 0 00-.364-1.118L2.13 9.384c-.783-.57-.38-1.81.588-1.81h4.154a1 1 0 00.95-.69l1.286-3.957z" />
          </svg>
          <span class="ml-2 text-gray-700 font-semibold">{modalContent.rating} / 5</span>
        </div>
        <button
          on:click={handleClose}
          class="mt-4 bg-[#023e8a] text-white px-4 py-2 rounded-full shadow-md hover:bg-[#0077b6] transition-all duration-300 transform hover:scale-105"
        >
          Close
        </button>
      </div>
    </div>
  {/if}
  
  <style>
    /* Optional: Add additional styles or transitions here */
  </style>
  