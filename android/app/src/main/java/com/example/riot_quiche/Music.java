package com.example.riot_quiche;


public class Music {
    private String id;
    private String albumId;
    private String artistId;
    private String title;
    private String artist;
    private String album;
    private Long duration;
    private String artUri;
    private String path;
    private byte[] art;


    public Music () {}

    public Music (
            String id,
            String albumId,
            String artistId,
            String title,
            String artist,
            String album,
            Long duration,
            String artUri,
            String path,
            byte[] art) {

        this.id = id;
        this.albumId = albumId;
        this.artistId = artistId;
        this.title = title;
        this.album = album;
        this.artist = artist;
        this.duration = duration;
        this.artUri = artUri;
        this.path = path;
        this.art = art;
    }

    public String getId () {
        return id;
    }
    public String getAlbumId () {
        return albumId;
    }
    public String getArtistId () { return artistId; }
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
    public String getPath () { return path; }
    public byte[] getArt () { return art; }
}
