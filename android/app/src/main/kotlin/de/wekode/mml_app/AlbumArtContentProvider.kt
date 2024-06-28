package de.wekode.mml_app

import android.content.ContentProvider
import android.content.ContentResolver
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException
import java.util.concurrent.TimeUnit

class AlbumArtContentProvider : ContentProvider() {

    companion object {
        private val uriMap = mutableMapOf<Uri, Uri>()

        fun mapUri(uri: Uri): Uri {
            val path = uri.encodedPath?.substring(1)?.replace('/', ':') ?: return Uri.EMPTY
            val contentUri = Uri.Builder()
                .scheme(ContentResolver.SCHEME_CONTENT)
                .authority("de.wekode.mml_app")
                .path(path)
                .build()
            uriMap[contentUri] = uri
            return contentUri
        }
    }

    override fun onCreate() = true

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor? {
        val context = this.context ?: return null
        val remoteUri = uriMap[uri] ?: throw FileNotFoundException(uri.path)

        var file = File(remoteUri.path!!)

        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun query(
        uri: Uri,
        projection: Array<String>?,
        selection: String?,
        selectionArgs: Array<String>?,
        sortOrder: String?
    ): Cursor? = null

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<String>?
    ) = 0

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?) = 0

    override fun getType(uri: Uri): String? = null

}
