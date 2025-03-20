
<script setup>
import { ref, watch, onMounted } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import gql from 'graphql-tag'
import debounce from 'lodash.debounce'
import { computed } from 'vue'


const filteredStates = computed(() => result.value?.states || [])


const highlightMatch = (name) => {
  if (!search.value.trim()) return name

  const chars = search.value.trim().split('')
  let idx = 0
  let highlighted = ''

  for (const letter of name) {
    if (idx < chars.length && letter.toLowerCase() === chars[idx].toLowerCase()) {
      highlighted += `<strong>${letter}</strong>`
      idx++
    } else {
      highlighted += letter
    }
  }

  return idx === chars.length ? highlighted : name
}

const search = ref('')
const selectedState = ref(null)
let map, geoJsonLayer

const GET_STATES = gql`
  query States($name: String!) {
    states(name: $name) {
      id
      name
      geometry {
        type
        coordinates
      }
    }
  }
`

const { result, loading, refetch } = useQuery(GET_STATES, { variables: { name: '' } })

const debouncedRefetch = debounce((name) => {
  refetch({ name })
}, 300)

watch(search, (newSearch) => {
  const trimmedSearch = newSearch.trim();
  if (trimmedSearch) {
    debouncedRefetch(trimmedSearch);
  } else {
    selectedState.value = null;
    if (geoJsonLayer) {
      geoJsonLayer.setMap(null);
    }
    result.value = { states: [] };
  }
});




const highlightState = (state) => {
  selectedState.value = state
  if (geoJsonLayer) {
    geoJsonLayer.setMap(null)
  }

  geoJsonLayer = new google.maps.Data()

  geoJsonLayer.addGeoJson({
    type: 'Feature',
    geometry: state.geometry
  })

  geoJsonLayer.setStyle({
    fillColor: 'yellow',
    strokeColor: 'red',
    strokeWeight: 2
  })

  geoJsonLayer.setMap(map)

  const bounds = new google.maps.LatLngBounds()

  if (state.geometry.type === 'Polygon') {
    state.geometry.coordinates[0].forEach(coord => {
      bounds.extend(new google.maps.LatLng(coord[1], coord[0]))
    })
  } else if (state.geometry.type === 'MultiPolygon') {
    state.geometry.coordinates.forEach(polygon => {
      polygon[0].forEach(coord => {
        bounds.extend(new google.maps.LatLng(coord[1], coord[0]))
      })
    })
  }

  map.fitBounds(bounds)
}




onMounted(() => {
  map = new google.maps.Map(document.getElementById('map'), {
    center: { lat: 37.1, lng: -95.7 },
    zoom: 4,
    zoomControlOptions: {
      position: google.maps.ControlPosition.RIGHT_CENTER
    },
    streetViewControlOptions: {
      position: google.maps.ControlPosition.RIGHT_BOTTOM
    },
    fullscreenControlOptions: {
      position: google.maps.ControlPosition.RIGHT_TOP
    },
    mapTypeControl: false
  })
})
</script>

<template>
  <div id="container">
    <div id="search-box">
      <input v-model="search" placeholder="Type a state name..." />
      <ul v-if="!loading && filteredStates.length">
        <li
            v-for="state in filteredStates"
            :key="state.id"
            @click="highlightState(state)"
            v-html="highlightMatch(state.name)"
        ></li>
      </ul>
    </div>
    <div id="map"></div>
  </div>
</template>
