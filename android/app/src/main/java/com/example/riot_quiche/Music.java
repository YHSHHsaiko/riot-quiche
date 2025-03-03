package com.example.riot_quiche;


public class Music {
    private String id;
    private String title;
    private String artist;
    private String album;
    private Long duration;
    private String artUri;


    public Music () {}

    public Music (
            String id,
            String title,
            String artist,
            String album,
            Long duration,
            String artUri) {

        this.id = id;
        this.title = title;
        this.album = album;
        this.artist = artist;
        this.duration = duration;
        this.artUri = artUri;
    }

    public String getId () {
        return id;
    }
    public String getTitle () {
        return title;
    }
    public String getAlbum () {
        return album;
    }
    public String getArtist () {
        return artist;
    }
    public Long getDuration () {
        return duration;
    }
    public String getArtUri () {
        return artUri;
    }
}
