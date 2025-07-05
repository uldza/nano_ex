const ShowVideoRoom = {
  mounted() {
    this.bindEvents();
  },
  
  updated() {
    this.bindEvents();
  },

  bindEvents() {
    // Bind click events to room cards
    const roomCards = this.el.querySelectorAll('[data-room-id]');
    roomCards.forEach(card => {
      card.addEventListener('click', (e) => {
        e.preventDefault();
        this.handleRoomSelect(card);
      });
    });
  },

  handleRoomSelect(card) {
    const roomId = card.dataset.roomId;
    const roomName = card.dataset.roomName;
    const roomDescription = card.dataset.roomDescription;
    const roomVideoUrl = card.dataset.roomVideoUrl;
    const roomThumbnailUrl = card.dataset.roomThumbnailUrl;
    const roomFreeMinutes = card.dataset.roomFreeMinutes;
    const roomRequiresSubscription = card.dataset.roomRequiresSubscription;

    // Update room select section
    this.updateRoomSelect({
      id: roomId,
      name: roomName,
      description: roomDescription,
      video_url: roomVideoUrl,
      video_thumbnail_url: roomThumbnailUrl,
      free_minutes: roomFreeMinutes,
      requires_subscription: roomRequiresSubscription
    });

    // Show room select section
    this.showRoomSelect();
  },

  updateRoomSelect(room) {
    // Update room title
    const roomTitle = this.el.querySelector('#room-title');
    if (roomTitle) {
      roomTitle.textContent = room.name;
    }

    // Update room details
    const roomDetails = this.el.querySelector('#room-details');
    if (roomDetails) {
      let detailsText = '';
      if (room.description) {
        detailsText += room.description;
      }
      if (room.free_minutes && room.free_minutes > 0) {
        detailsText += ` • Free for ${room.free_minutes} minutes`;
      }
      if (room.requires_subscription === 'true') {
        detailsText += ' • Premium content';
      }
      roomDetails.textContent = detailsText;
    }

    // Update room video link
    const roomVideoLink = this.el.querySelector('#room-video-link');
    if (roomVideoLink) {
      roomVideoLink.href = `/rooms/${room.id}`;
    }
  },

  showRoomSelect() {
    const roomSelect = this.el.querySelector('#room-select');
    if (roomSelect) {
      roomSelect.classList.remove('hidden');
      
      // Scroll to room select section
      roomSelect.scrollIntoView({ 
        behavior: 'smooth', 
        block: 'start' 
      });
    }
  }
};

export default ShowVideoRoom;